<?php

define('DIR',dirname(__FILE__));
define('DEPEND',DIR.'/.depend.json');

function ext($file)  
{
  $part = pathinfo($file);
  return array($part['filename'],$part['extension']);
}

function run($dir,$command) 
{
//  echo $command, "\n";

  ob_start();
  $start = microtime(true);
  if ($dir != '.') chdir(DIR.'/'.$dir);
  passthru($command.' 2>&1',$result);
  chdir(DIR);
  $end = microtime(true);
  $output = ob_get_clean();
  return array($result,$output,($end-$start)*1000);
}

function flags($dir) 
{
  $ppflags = ' -syntax camlp4o -package json-static';
  if ($dir != 'ozone') $ppflags .= ' -ppopt "'.DIR.'/p4/pa_monad.cmo"';
  $ccflags = ' -package batteries -package netcgi2';
  $lnflags = ' -linkpkg -package netclient -package json-wheel -package sha -package curl';
  if ($dir != '.') $ccflags .= ' -I ..';

  return $ppflags.$ccflags.$lnflags; 
}

function find_unbound_module($output)
{
  if (!preg_match('/Unbound module ([A-Za-z0-9_]+)/',$output,$matches))
    return null;

  return $matches[1];
}

function find_forward_reference($output)
{
  if (!preg_match('/reference to ([A-Za-z0-9_]+) in file ([A-Za-z0-9_]+)/',$output,$matches))
    return null;

  return array($matches[2],lcfirst($matches[1]));
}

function find_dependency($output)
{
  if (!preg_match('/Error while linking ([A-Za-z0-9_]+)/',$output,$matches))
    return find_forward_reference($output);
  
  $dependent = $matches[1];
 
  if (!preg_match('/Reference to undefined global `([A-Za-z0-9_]+)/',$output,$matches))
    return null;
   
  $dependency = lcfirst($matches[1]);

  return array($dependent,$dependency);
}

function find_inconsistency($output)
{
  if (!preg_match('<[./]*([a-zA-Z0-9_]+).cm[xoi] and [./]*([a-zA-Z0-9_]+).cm[xoi]>',
      $output,$matches))
    return null;

  $fileA = $matches[1];
  $fileB = $matches[2];

  if (!preg_match('/over interface ([a-zA-Z0-9_]+)/',$output,$matches))
    return null;   

  $interface = lcfirst($matches[1]);

  return ($interface == $fileA) ? array($fileB) :
         (($interface == $fileB) ? array($fileA) : array($fileA,$fileB)) ; 
}

function move_before($array,$what,$before)
{
  $old = array_search($what,  $array);
  $new = array_search($before,$array);

  if ($new >= $old) return $array;

  return array_merge(
    array_slice($array,0,$new),
    array($what),
    array_slice($array,$new,$old-$new),
    array_slice($array,$old+1)
  );
}

$dependencies = is_readable(DEPEND)
  ? json_decode(file_get_contents(DEPEND),true)
  : array();

function get_dependencies($dir)
{
  global $dependencies;
  return isset($dependencies[$dir]) ? $dependencies[$dir] : array();
}

function get_dependencies_ext($dir,$ext)
{
  $out = array();
  foreach (get_dependencies($dir) as $file) $out[] = $file.'.'.$ext;
  return $out;
}

function set_dependencies($dir,$d)
{
  global $dependencies;
  $dependencies[$dir] = $d;
}

function update_dependencies($dir,$dependent,$dependency)
{
  echo "$dir/$dependent: $dir/$dependency\n";

  set_dependencies($dir,
    move_before(
      get_dependencies($dir),
      $dependency,
      $dependent
    )
  );    
}

function upgrade_dependencies($dir,$more)
{
  $out = array();
  $old = get_dependencies($dir);
  foreach ($old as $file) 
    if (in_array($file,$more)) $out []= $file;
  foreach ($more as $file)
    if (!in_array($file,$out)) $out []= $file;
  set_dependencies($dir,$out);
}

$cc_cycle_detection = array();

function cc($dir,$target)
{
  global $cc_cycle_detection;
  if (isset($cc_cycle_detection["$dir/$target"])) {
    echo "$dir/$target: circular dependency detected\n";
    return false;
  }

  $cc_cycle_detection["$dir/$target"] = true;

  $result = cc_do($dir,$target);

  unset($cc_cycle_detection["$dir/$target"]);
  return $result;
}

function cc_do($dir,$target)
{
  $prefix = DIR.'/'.$dir.'/';
  list($file,$ext) = ext($target);
  
  $source = $file.'.ml';
  if ($ext == 'cmi' && is_readable($prefix.$file.'.mli')) $source = $file.'.mli';

  for ($i = 0; $i < 100; ++$i) 
  {
    if (is_readable($prefix.$target) && 
        filemtime($prefix.$target) >= filemtime($prefix.$source)) return true; 

    $flags   = flags($dir);
    $command = "ocamlfind ocamlc $flags -c $source";
  
    list($failed,$output,$time) = run($dir,$command);

    if (!$failed) {
      printf("[%4d] ocamlc -c %s/%s\n",$time,$dir,$source);  
      flush();
      return true;
    }

    $Module = find_unbound_module($output); 

    if ($Module !== null) 
    {
      $module = lcfirst($Module);
      update_dependencies($dir,$file,$module);
      if (cc($dir,$module.'.cmi') && cc($dir,$module.'.cmo')) continue;
      return false;
    }

    $inconsistencies = find_inconsistency($output);
   
    if ($inconsistencies !== null)
    {
      if (re_cc($dir,$inconsistencies)) continue;
      return false;
    }

    echo "$dir/$source:\n$output\n";
    return false;
  }

  return false;
}

$recompiled = array();

function re_cc($dir,$file)
{
  if (is_array($file))
  {
    $r = true;
    foreach ($file as $f) $r = $r && re_cc($dir,$f);
    return $r;
  }

  global $recompiled;
  if (isset($recompiled["$dir/$file"]))
    return true;

  $recompiled["$dir/$file"] = true;

  $prefix = DIR.'/'.$dir.'/';
  @unlink($prefix.$file.'.cmo');
  @unlink($prefix.$file.'.cmi');	
  return cc($dir,$file.'.cmi') && cc($dir,$file.'.cmo');
}

function cmicheck($dir)
{
  $prefix = DIR.'/'.$dir.'/';

  ob_start();
  foreach (get_dependencies($dir) as $name) 
    echo 'module ', ucfirst($name), ' = ', ucfirst($name), "\n"; 
  $file = $prefix.'cmicheck.ml';
  file_put_contents($file,ob_get_clean());

  $flags   = flags($dir);
  $command = "ocamlfind ocamlc $flags -c $file";
  
  for ($i = 0; $i < 100; ++$i)
  {
    list($failed,$output,$time) = run($dir,$command);

    if ($failed) 
    {
      $inconsistencies = find_inconsistency($output);
      if (isset($inconsistencies) && re_cc($dir,$inconsistencies))
        continue;
      return false;
    } 

    unlink($file);
    return true;
  }

  echo "$dir:\n$output";

  return false;
}

function ln($dir)
{
  $prefix = DIR.'/'.$dir.'/';

  $targets = array(
    'ozone' => 'ozone',
    'config' => 'config',
    'id' => 'i',
    'model' => 'm',
    'form' => 'f',
    'view' => 'v',
    'url' => 'url',
    'ctrl' => 'c',
    'test' => 'test',
  );

  foreach (get_dependencies($dir) as $file)
  {
    if (cc($dir,$file.'.cmi') && cc($dir,$file.'.cmo')) continue;
    echo "$dir: fatal compile error\n";
    return false;
  } 
  
  $flags  = flags($dir);

  if (!cmicheck($dir))
    return false;

  for ($i = 0; $i < 100; ++$i) 
  {
    if ($dir == '.')
    {
      $source = 'ozone.cmo config.cmo i.cmo js.cmo m.cmo f.cmo v.cmo url.cmo c.cmo main.cmo';
      $dest   = "../build/baryton";
    }
    else
    {
      $source = implode(' ',get_dependencies_ext($dir,'cmo'));
      $target = $targets[$dir];
      $dest   = $target.'.cmo';
    }

    $command = "ocamlfind ocamlc $source -pack -o $dest";

    list($failed,$output,$time) = run($dir,$command);

    if (!$failed) 
    {
      if ($dir != '.')
        printf("====== ocamlc %s/*.cmo -pack %s.cmo\n",$dir,$target);  
      else
        printf("====== ocamlc %s/*.cmo %s\n",$dir,$dest);  
      flush();

      if ($dir != '.')
      {
	copy($prefix.$target.'.cmo',DIR.'/'.$target.'.cmo');
	copy($prefix.$target.'.cmi',DIR.'/'.$target.'.cmi');
      }
      
      return true;
    }

    $rule = find_dependency($output);

    if ($rule !== null) 
    {
      list($dependent,$dependency) = $rule;  
      update_dependencies($dir,$dependent,$dependency);
      continue;
    }

    $inconsistent = find_inconsistency($output);
   
    if ($inconsistent !== null)
    {
      if (re_cc($dir,$inconsistent)) continue;
      echo "$dir: fatal compile error\n";
      return false;
    }

    echo "$dir:\n$output\n";
    return false;
  }
}

function re_ln($dir)
{
  $prefix = DIR.'/'.$dir.'/';
  foreach (get_dependencies_ext($dir,'cmi') as $file) @unlink($prefix.$file);
  foreach (get_dependencies_ext($dir,'cmo') as $file) @unlink($prefix.$file);
  return ln($dir);
}

foreach(array('ozone','config','id','model','form','view','url','ctrl'/*,'test'*/,'.') as $dir)
{
  $prefix = DIR.'/'.$dir.'/';
  $mlfiles = array();
  foreach (glob($prefix.'/*.ml') as $ml)
  {
    list($file) = ext($ml);
    $mlfiles []= $file;
  }

  upgrade_dependencies($dir,$mlfiles);  
}

$result = ln('ozone')
  && re_cc('.','js')
  && ln('config')
  && ln('id')
  && ln('model')
  && ln('form')
  && ln('view')
  && ln('url')
  && ln('ctrl')
//  && ln('test')
  && ln('.','baryton.out');

file_put_contents(DEPEND,json_encode($dependencies));

exit($result ? 0 : 1);