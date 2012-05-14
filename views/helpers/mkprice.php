<?php

$prices = array(
  50  => 72,
  100 => 120,
  150 => 180,
  250 => 300,
  350 => 420,
  500 => 540,
  750 => 810,
  1000 => 1080,
  1500 => 1620,
  2000 => 2160,
  2500 => 2700,
  3500 => 3780,
  5000 => 5400
);

$hide = array( 150, 350, 750, 1500, 2000, 2500, 3500, 5000 );

ob_start();

echo '<table class="pricing"><thead><tr><td></td><td>Accès</td><td>Espace disque</td><td>Prix annuel HT</td></tr></thead><tbody>';

foreach ($prices as $seats => $price) {

  $hidden = in_array($seats, $hide);
  $offer = 'Org'.$seats;
  $memory = str_replace('.',',',sprintf("%g",$seats/100));
  $monthly = str_replace('.',',',sprintf("%g",$price/12));
  $seat = str_replace('.',',',sprintf("%.2f",$price/12/$seats));

  echo '<tr', ($hidden ? ' style="display:none"': ''), '><td class="-offer">', 
    $offer, '</td><td class="-amt"><span>',
    $seats, '</span>Membres</td><td class="-amt"><span>',
    $memory, '</span>Giga-octets</td><td class="-price"><span>', 
    $price, ' €</span>soit ', $monthly, '€/mois, ', $seat, '€/membre/mois</td></tr>';
}

echo '<tr class="-more"><td colspan="4"><a href="javascript:void(0)" onclick="',
  htmlspecialchars('if($){$(this).closest("table").find("tr").show();$(this).closest("tr").hide()}'),
  '">Afficher les formules intermédiaires</a></td></tr>';

echo '</tbody></table>';

file_put_contents(dirname(__FILE__).'/prices.htm', ob_get_clean());

$prices = array(
  1 => 2,
  2 => 4,
  5 => 10,
  10 => 20
);

ob_start();

echo '<table class="pricing"><thead><tr><td></td><td>Espace disque</td><td>Prix mensuel HT</td></tr></thead><tbody>';

foreach ($prices as $memory => $price) {
  $offer = 'Org'.$memory.'G';
  $yearly = $price * 12;

  echo '<tr><td class="-offer">', $offer, '</td><td class="-amt"><span>',
    $memory, '</span>Giga-octets</td><td class="-price"><span>', $price, ' €</span>soit ', $yearly, '€/an </td></tr>';
}

echo '</tbody></table>';

file_put_contents(dirname(__FILE__).'/memory-prices.htm', ob_get_clean());