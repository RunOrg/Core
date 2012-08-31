| `Notify_List_Empty 

| `Notify of [ `NewInstance1
	     | `NewJoin1
	     | `NewUser1
	     | `BecomeAdmin1 of Ohm.AdLib.gender
	     | `BecomeMember1
	     | `NewFavorite1 
	     | `NewCommentSelf1 
	     | `NewCommentOther1
	     | `NewCommentOther2
	     | `NewWallItem1
	     | `EntityInvite1
	     | `EntityInvite2
	     | `EntityRequest1
	     | `EntityRequest2
	     | `Whatever 
	     ]

| `Notify_Expired_Title
| `Notify_Expired_Body 

| `Notify_Title
| `Notify_Settings_Title
| `Notify_Settings_Choice of [ `Default
			     | `Everything
			     | `Relevant
			     | `Nothing 
			     ]
| `Notify_Settings_Detail of [ `Everything
			     | `Relevant
			     | `Nothing 
			     ]
| `Notify_Settings_Submit 
| `Notify_Settings_Default

| `Notify_Link_Settings
