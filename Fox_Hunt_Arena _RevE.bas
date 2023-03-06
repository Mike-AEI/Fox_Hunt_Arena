
   ;***************************************************************
   ;
   ;  FOX HUNT - AREANA
   ;  Instructions:
   ;  
   ;  Use the joystick to move the Fox. 
   ;***************************************************************


   ;***************************************************************
   ;
   ;  Setup System
   ;
   set romsize 32k
   set optimization inlinerand
   


   ;***************************************************************
   ;  Variable Defines/Dimention
   ;***************************************************************
   
   ;```````````````````````````````````````````````````````````````
   ;  Player Features
   ;   Bit 0 = Has Key
   ;   Bit 1 = Key is Available/displayed
   ;   Bit 2 = Has Bow
   ;   Bit 3 = Has XG7
   ;   bit 5 = Reflected (going left)
   ;  
   dim _Player_Fetaures = c
   dim _Has_Key_Bit0 = c
   dim _Display_Key_Bit1 = c
   dim _Has_Bow_Bit2 = c
   dim _Has_XG7_Bit3 = c
   dim _Has_Shield_Bit4 = c
   dim _Has_Shockproof_bit5 = c
   dim _Has_Code_A_Bit6 = c
   dim _Has_Code_B_Bit7 = c

   dim _Round_Number_Bits012 = n
   dim _Round_LSB_Bit0 = n
   dim _Round_Mid_Bit1 = n
   dim _Round_MSB_Bit2 = n
   dim _Cash_In_Room_Bit4  = n
   dim _Player0_Reflected_Bit5 = n
   dim _Spare_Bit6 = n
   dim _Spare_Bit7 = n

   dim _Shield_Position_Counter = o
   

   ;```````````````````````````````````````````````````````````````
   ;  Station Has an Object
   ;   bit = 0 = no object, 1 = Has Object
   ;  
   dim _Station_Filled= d
   dim _Station_Contents_Pointers = a


   ;```````````````````````````````````````````````````````````````
   ;  Animation Variables
   ;  
   dim _Animation_Counter = b


   ;```````````````````````````````````````````````````````````````
   ;  playfield Features
   ;    bits 0-3 Location of the Station
   ;    bits 4-5 Enemy character 0 = none, 1 = Nova, 2 = Bob, 3 = Carl
   ;    Bits 6-7 Likelyhood of Enemy 0 = 12% 2 = 25% 3 = 50% 4 = 100%
   ;    Station Location 0 = none. Station X = (Bits01 * 7)+4 Station Y = (Bits23 *2) + 2
   ;  
   dim _Playfield_Features = e

   ;```````````````````````````````````````````````````````````````
   ;  Present playfield 
   ;    bits 0-3 are y screen position  0 = topmost
   ;    bits 4-7 are X screen position  0 = leftmost
   ;      
   dim _Present_Playfield = f

   ;```````````````````````````````````````````````````````````````
   ;  Player0/missile0 direction bits.
   ;
   dim _BitOp_P0_M0_Dir = g
   dim _Bit0_P0_Dir_Up = g
   dim _Bit1_P0_Dir_Down = g
   dim _Bit2_P0_Dir_Left = g
   dim _Bit3_P0_Dir_Right = g
   dim _Bit4_M0_Dir_Up = g
   dim _Bit5_M0_Dir_Down = g
   dim _Bit6_M0_Dir_Left = g
   dim _Bit7_M0_Dir_Right = g

   ;```````````````````````````````````````````````````````````````
   ;  Enemy direction bits.
   ;
   dim _BitOp_P1_Dir = h
   dim _Bit0_P1_Dir_Up = h
   dim _Bit1_P1_Dir_Down = h
   dim _Bit2_P1_Dir_Left = h
   dim _Bit3_P1_Dir_Right = h
   dim _Bit4_P1_Injured = h 
   dim _Bit5_P1_Reflected= h 
   dim _Bit6_New_Playfield = h    
   dim _Bit7_Enemy_Move_Skip = h



   ;```````````````````````````````````````````````````````````````
   ;  Additional Enemy information
   ;
   dim _Enemy_Info = i
   dim _Bit0_Nova_Dead = i
   dim _Bit1_Bob_Dead = i
   dim _Bit2_Carl_Dead = i
   dim _No_Enemy_Present_Bit3 = i
   dim _Nova_Present_Bit4 = i
   dim _Bob_Present_Bit5 = i
   dim _Carl_Present_Bit6 = i


   ;```````````````````````````````````````````````````````````````
   ;  Arrows and lazer blasts are time limimted
   ;
   dim _Shot_Counter = j

   ;```````````````````````````````````````````````````````````````
   ;  Touching the walss to long is "shocking"
   ;
   dim _Touch_Counter = k

   ;```````````````````````````````````````````````````````````````
   ;  Animating the Station ball contents
   ;
   dim _Ball_Animator= l

   ;```````````````````````````````````````````````````````````````
   ; Freeze the character movement
   ;
   dim _Frozen= m



   ;```````````````````````````````````````````````````````````````
   ;  Channel 0 sound variables.
   ;
   dim _Ch0_Sound = q
   dim _Ch0_Duration = r
   dim _Ch0_Counter = s
   dim _Ch1_Duration = t


  
   ;```````````````````````````````````````````````````````````````
   ;  u and v used for channel 1 sdata.
   ;,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,

   ;```````````````````````````````````````````````````````````````
   ;  Bits that do various jobs.
   ;
   dim _Bit0_Reset_Restrainer = y
   dim _Bit7_M0_Moving = y

   ;```````````````````````````````````````````````````````````````
   ;  Makes better random numbers.
   ;
   dim rand16 = z



   ;***************************************************************
   ;
   ;  Defines the edges of the playfield for an 8 x 8 sprite.
   ;  If your sprite is a different size, you'll need to adjust
   ;  the numbers.
   ;
   const _P_Edge_Top = 9
   const _P_Edge_Bottom = 88
   const _P_Edge_Left = 14
   const _P_Edge_Right = 138



   ;***************************************************************
   ;
   ;  Defines the edges of the playfield for the missile.
   ;  If the missile is a different size, you'll need to adjust
   ;  the numbers.
   ;
   const _M_Edge_Top = 2
   const _M_Edge_Bottom = 88
   const _M_Edge_Left = 22
   const _M_Edge_Right = 140


   ;***************************************************************
   ;***************************************************************
   ;
   ;  PROGRAM START/RESTART
   ;
   ;
__Start_Restart

   
   ;***************************************************************
   ; Round Station Data
   ;*******************************
   ;  3 stations in rounds 1 &and 2
   ;  5 stations in rounds 3 & 4
   ;  8 stations in rounds 5 & 6
   ;  16 data pints are used to allow for the random offset
   ;      0=health  1=shock  2=Bow 
   ;      3=Code_Key A 4 = Code_key B 
   ;      5 = XG7 6 = Shockproof 7 = Shield
   data _Round_One ; Only Helth
   0,0,0,0,0,0
end

   data _Round_Two ; Health & shield
   0,7,0,0,7,0
end

   data _Round_Three ; Health & Bow
   0,2,0,0,0,0,2,0,0,0
end
 
   data _Round_Four ; Code A, Shield & Health
   7,0,3,0,0,7,0,3,0,0
end   
  
   data _Round_Five ; Shockproof, Shield, Health
   0,6,0,6,0,7,0,0,0,7,0,6,0,7,0,0
end

   data _Round_Six ; XG7, Shield, Shockproof, Health
   0,7,6,0,7,0,5,0,0,6,6,0,7,0,5,0
end

   data _Round_Seven ;Code B, Zap, Health
   1,0,1,0,0,1,4,0,1,0,1,0,0,1,4,0
end


   ;***************************************************************
   ;
   ;  Mutes volume of both sound channels.
   ;
   AUDV0 = 0 : AUDV1 = 0


   ;***************************************************************
   ;
   ;  Clears all normal variables except for z (used for rand).
   ;
   a = 0 : b = 0 : c = 0 : d = 0 : e = 0 : f = 0 : g = 0 : h = 0 : i = 0
   j = 0 : k = 0 : l = 0 : m = 0 : n = 0 : o = 0 : p = 0 : q = 0 : r = 0
   s = 0 : t = 0 : u = 0 : v = 0 : w = 0 : x = 0 : y = 0



   ;***************************************************************
   ;
   ;  set up the Score, lives and Health
   ;
   const pfscore = 1
   const font = retroputer
   ;const font = alarmclock
   scorecolor = $C4
   pfscorecolor = $1A
   pfscore1 = %11011011 ; enemy have all lives
   _Bit0_Nova_Dead{0} = 0
   _Bit1_Bob_Dead{1} = 0
   _Bit2_Carl_Dead{2} = 0
   pfscore2 = %11111111 ; player at Full Health


   ;***************************************************************
   ;
   ;  Sets starting position of enemy.
   ;
   player1y = 44
   player1x = 80

   ;***************************************************************
   ;
   ;  Makes sure missile0 is off the screen.
   ;
   missile0x = 200 : missile0y = 200


   ;***************************************************************
   ;
   ;  Defines missile and heights.
   ;
   missile0height = 1
   missile1height = 1
   ballheight = 2


   ;***************************************************************
   ;
   ;  Sets playfield and background colors.
   ;
   COLUPF = $08
   COLUBK = $00
   

   ;***************************************************************
   ;
   ;  Sets beginning direction that missile0 will shoot if the
   ;  player doesn't move.
   ;
   _Bit3_P0_Dir_Right{3} = 1


   ;***************************************************************
   ;
   ;  Restrains the reset switch for the main loop.
   ;
   ;  This bit fixes it so the reset switch becomes inactive if
   ;  it hasn't been released after being pressed once.
   ;
   _Bit0_Reset_Restrainer{0} = 1


   ;***************************************************************
   ;
   ;  Defines shape of player0 sprite.
   ;
Fox
 player0:
 %01001000
 %01001000
 %01101000
 %00110000
 %00111100
 %00110000
 %00011000
 %00011000
end
  
  
Nova
 player1:
 %00000000
 %00000000
 %00000000
 %00000000
 %00000000
 %00000000
 %00000000
 %00000000
end  

   ;**************************
   ;   Title Screen
   ;
   goto __Title_Screen bank2
   
__Return_From_Title
   
   ;***************************************************************
   ;
   ;  Sets starting position of player0.
   ;
   player0x = 36 : player0y = 28


   ;***************************************************************
   ;
   ;  Set up the playfield to location x=0 y=0
   ;     all Playfields are stored in bank3
   ;
   _Present_Playfield  = $00
   _Playfield_Features = %00000000
__Field_Start
 playfield:
 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
 XX......XX.....................X
 X...............................
 X...............................
 XX......XX......................
 XXXXXXXXXX......................
 X...............................
 X...............................
 X...............................
 X...............................
 XX.............................X
end

  
   
   ;***************************************************
   ; Round One Setup
   ;***************************************************
   ; Fill only stations 0-2
   ; Find a random room, 00 to 22 for the key
   ; And it will also offset the data 0-2 positions so objects are placed randomly in stations
   ;
   _Round_Number_Bits012 = 1

   _Station_Filled = %00000111 ; first 3 stations are filled, but locked as Fix has no key
   
   temp4 = rand&3 :  if temp4 > 2 then temp4 = 2
   temp5 = rand&3 :  if temp5 > 2 then temp5 = 2
   temp5 = temp5 * 16 
   _Station_Contents_Pointers = temp4 + temp5; Sets the offset into the station data (what's inside) and the room where the Key is found
   
   _No_Enemy_Present_Bit3{3} = 1

  
   
   ;*****************************************************************
   ;  Game Options: 
   ;    left Difficulty sets with or without Key at start
   ;    right  Difficulty sets with or without Bow at start

   ;if switchrightb then pfscore2 = %11111111 ; Start with full health
   ;if switchleftb then _Has_Key_Bit0{0} = 1  ; Start with Key
 
    score = 100000 ; Start at 1/2 a million 
 
   ;***************************************************************
   ;***************************************************************
   ;
   ;  MAIN LOOP (MAKES THE PROGRAM GO)
   ;
   ;
__Main_Loop
   
   score = score - 10
   

   if switchleftb then _Frozen = 0 ; Fox does not get frozen when touching the wall when left is set to EASY
   
   if _Bit5_P1_Reflected{5} then  REFP1 = $08 else REFP1 = $00 
   
   ;***************************************************************
   ;
   ;  Sets color of player0 and 1 sprite and missile.
   ;  set the Playfield color.. do this every loop as he Score is a diferent color
   ;  if sound 4 (hit enemy) is playing, flash the player 0 colors
   ;
   if _Ch0_Sound <>4 then COLUP0  = $9C ; Player 0 color = blue unless touched by an enemy or frozen
   if _Frozen then COLUP0 = $46
   temp4 = _Present_Playfield & $0F
   COLUPF = 12 - temp4*2 ; playfield gets darker as you go down deeper
   
   ;***************************************************************
   ;
   ;  Defines missile0 width.
   ;
   NUSIZ0 = $10 ; 2 pixel wide missle 0
   NUSIZ1 = $10 ; 2 pixel high missle 1


   ;***************************************************************
   ; Station Control
   ;    if there is a station on this playfield
   ;    and the Fox has the Key...
   ;    and this one is full, then place the Ball into the Station
   ;
   
   if !_Has_Key_Bit0{0} then goto __Skip_Stations_Full
   if _Present_Playfield = $02 && !_Station_Filled{0} then AUDV1 = 0: goto __Skip_Stations_Full
   if _Present_Playfield = $12 && !_Station_Filled{1} then AUDV1 = 0: goto __Skip_Stations_Full
   if _Present_Playfield = $21 && !_Station_Filled{2} then AUDV1 = 0: goto __Skip_Stations_Full
   if _Present_Playfield = $23 && !_Station_Filled{3} then AUDV1 = 0: goto __Skip_Stations_Full
   if _Present_Playfield = $31 && !_Station_Filled{4} then AUDV1 = 0: goto __Skip_Stations_Full
   if _Present_Playfield = $14 && !_Station_Filled{5} then AUDV1 = 0: goto __Skip_Stations_Full ;  Moved!!
   if _Present_Playfield = $40 && !_Station_Filled{6} then AUDV1 = 0: goto __Skip_Stations_Full
   if _Present_Playfield = $44 && !_Station_Filled{7} then AUDV1 = 0: goto __Skip_Stations_Full
   
   ;  Claulate the position of the station to place the object/ball... it will rotate/animate
   if !_Playfield_Features&$0F then ballx = 200 : bally = 200 : AUDV1 = 0 :goto __Skip_Stations_Full ; No station on this playfield
   temp4 = _Playfield_Features & $03
   temp5 = (temp4*32) + 27
   temp4 = _Playfield_Features & $0C
   temp6 = (temp4 * 4) + 20
   _Ball_Animator = _Ball_Animator + 10
   if _Ball_Animator= 80 then _Ball_Animator = 0
   if _Ball_Animator= 0  then ballheight =4 : AUDV1 =1: CTRLPF = $11  : ballx = temp5   : bally = temp6    ; Tall/thin on left
   if _Ball_Animator= 20 then ballheight =1 : AUDV1 =0: CTRLPF = $21 : ballx = temp5+2 : bally = temp6-3  ; Short/Wide of top
   if _Ball_Animator= 40 then ballheight =4 : AUDV1 =1: CTRLPF = $11 : ballx = temp5+4 : bally = temp6+2  ; tall/thin on right
   if _Ball_Animator= 60 then ballheight =1 : AUDV1 =0: CTRLPF = $21 : ballx = temp5   : bally = temp6+2  ; Short/Wide on bottom
   AUDC1=7 : AUDF1=1
   
__Skip_Stations_Full

   ;***********************************************************************
   ; Enemey Control
   ;    Diferent playfieds are protected by different enemies
   ;    and each playfield has differnt chance of the enemy being there
   ; 
   ;***** set the enemey color, has to be done on every Main loop *********
   temp4 = _Playfield_Features & $30
   if temp4 = $10 then COLUP1 = $44 ; Nova red
   if temp4 = $20 then COLUP1 = $64 ; Bob purple
   if temp4 = $30 then COLUP1 = $F4 ; Carl brown
   if temp4 = $00 then COLUP1 = $00 ; Nothing
   if player1x > _P_Edge_Right then COLUP1 = $00  ;  blank out players beyond the bounderies
   if player1x < _P_Edge_Left then COLUP1 = $00   ;  blank out players beyond the bounderies
   if player1y > _P_Edge_Bottom then COLUP1 = $00 ;  blank out players beyond the bounderies
   if player1y < _P_Edge_Top then COLUP1 = $00    ;  blank out players beyond the bounderies
   
   if _Cash_In_Room_Bit4{4} then COLUP1 = $C6 ; Green
   if _Display_Key_Bit1{1} then COLUP1 = $FC ; Gold

   ;*******************************************************************
   ; NEW playfield, 
   ;     Detemine if is the right chance to show the enemy 
   ;     This could be the room with the Key, which also uses sprite 1
   ;     Kill any previous missile in flight
   ;
   if !_Bit6_New_Playfield{6} then goto __Skip_New_Playfield_Setup
   
   _Bit6_New_Playfield{6} = 0 ; we do this next stuff once per screen change

   _Bit7_M0_Moving{7} = 0 : missile0x = 200 : missile0y = 200  ; Kill any missle that may have been in flight on the last screen
   
   _Enemy_Info = _Enemy_Info & %00001111 ; Clear all the enemy present bits but leave the Enemy dead bits alone

   if !_Has_Key_Bit0{0} && _Present_Playfield = _Station_Contents_Pointers  then goto __No_Enemy ; This is the room to display the key
   
   temp4 = _Playfield_Features & $C0 ; What is the chance of  having an enemy on this playfield?
   if temp4 = $00 then temp5 = 255  ; no chance for enemy to show
   if temp4 = $40 then temp5 = 3    ; 25% chance for enemy to show
   if temp4 = $80 then temp5 = 1    ; 50% chance for enemy to show
   if temp4 = $C0 then temp5 = 0    ; 100% chance for enemy to show
   temp4 = rand&temp5
   if temp4 then _No_Enemy_Present_Bit3{3} = 1 :  goto __No_Enemy
   
   ; There is an emeny in this room
   _Display_Key_Bit1{1} = 0 		; Enemy displayed, not and object, so move enemy
   _No_Enemy_Present_Bit3{3} = 0 		; An enemy IS present
   temp4 = _Playfield_Features & $30 	; Find what character should be displayed
   if temp4 = $10 then _Nova_Present_Bit4{4} = 1 
   if temp4 = $20 then _Bob_Present_Bit5{5}  = 1  
   if temp4 = $30 then _Carl_Present_Bit6{6} = 1 

   ; set a new enemy starting location for the enemy
   temp4 = rand&63
   player1y = temp4+ 15
   temp4 = rand&127 
   player1x = temp4 + 32
   _Cash_In_Room_Bit4{4} =0 ; Display and Enemy, not Cash
   
  goto __Enemy_Selected

__No_Enemy
  ;************************************************************
  ;  Not and enemay, but could be a Key or Cash
  ; Determine if the key should be displayed
  ;if _Present_Playfield <> _Station_Contents_Pointers  then goto __Blank bank3 	; This is the wrong room, blank and leave
  if _Present_Playfield <> _Station_Contents_Pointers  then goto __Cash bank3    ; Test to see if Cash works
  if _Has_Key_Bit0{0} then _Display_Key_Bit1{1} = 0  : goto __Blank bank3 		; Player already has a key, Blank enemy and skip to Enemy Selected
  ; Display the Key
  _Display_Key_Bit1{1} = 1 ; Stops movement while an object is displayed 
  player1x = 72 : player1y = 56 
  goto __Key bank3 
  
__Enemy_Selected

__Skip_New_Playfield_Setup

__Player_Selected

  ;*******************************************************************
  ; See if the Player is colliding with the playfield 
  ; if too long, then you get zapped and frozen
  ;  Unless you have the Shockproof cloak
  ;
  if !collision(playfield,player0) then __Skip_Collision_Fix
  if _Has_Shockproof_bit5{5} then __Skip_Collision_Fix
  _Touch_Counter = _Touch_Counter + 1
  if _Touch_Counter > 12 then _Touch_Counter= 0 : _Animation_Counter = 0:  goto __Zapped bank2 ; Touched the wall too long!!! 
  if _Bit0_P0_Dir_Up{0} then player0y = player0y +1 : goto __Skip_Collision_Fix
  if _Bit1_P0_Dir_Down{1} then player0y = player0y -1 : goto __Skip_Collision_Fix
  if _Bit2_P0_Dir_Left{2} then player0x = player0x +1 : goto __Skip_Collision_Fix
  if _Bit3_P0_Dir_Right{3} then player0x = player0x -1 : goto __Skip_Collision_Fix

__Skip_Collision_Fix

   ;***************************************************************
   ;
   ;  Joystick movement precheck.
   ;
   ;```````````````````````````````````````````````````````````````
   ;  Selects the player at rest and Skips section if joystick hasn't been moved.
   ;
   if !joy0up && !joy0down && !joy0left && !joy0right then _Animation_Counter = 255 : goto __Player_Animation bank3
   if _Frozen then _Frozen = _Frozen-1 : goto __Done_Moving

   ;```````````````````````````````````````````````````````````````
   ; Clears player0 direction bits since joystick has been moved.
   ; Play the Walking sound and analimate the player
   ;
   _BitOp_P0_M0_Dir = _BitOp_P0_M0_Dir & %11110000
   if _Ch0_Sound =0 then _Ch0_Sound = 5: _Ch0_Duration = 1 : _Ch0_Counter = 0 ; Walking
   goto __Player_Animation bank3

__Return_From_Animation

__Skip_Joystick_Precheck
      
   ;.........................................................................
   ;  set the player facing left or right based on the last known direction
   ;
   if _Player0_Reflected_Bit5{5} then REFP0 = $08 else REFP0 = $00
   
   ;***************************************************************
   ;
   ;  Joy0 up check.
   ;
   ;```````````````````````````````````````````````````````````````
   ;  Skips this section if joystick isn't moved up.
   ;
   if !joy0up then goto __Skip_Joy0_Up

   ;```````````````````````````````````````````````````````````````
   ;  Turns on the up direction bit.
   ;
   _Bit0_P0_Dir_Up{0} = 1

   
   ;```````````````````````````````````````````````````````````````
   ; goto next screen and reset position if at top edge
   ;
   if player0y > _P_Edge_Top then goto __Move_Up
   
   player0y = _P_Edge_Bottom
   if _Present_Playfield & $0F > $00 then _Present_Playfield = _Present_Playfield  - $01 : _Bit6_New_Playfield{6} = 1 
   ;goto __Next_Playfield bank3 
   ;goto __Next_3x3_Playfield bank4     
   goto __Find_Next_Room
   
__Move_Up
  
   player0y = player0y - 1
   if !collision(playfield,player0) then goto __Skip_Joy0_Up
   _Touch_Counter = _Touch_Counter + 1
   ;player0y = player0y + 2 ; hit the wall, reset position
   
__Skip_Joy0_Up



   ;***************************************************************
   ;
   ;  Joy0 down check.
   ;
   ;```````````````````````````````````````````````````````````````
   ;  Skips this section if joystick isn't moved down or if joystick is Up
   ;
   if !joy0down then goto __Skip_Joy0_Down
   

   ;```````````````````````````````````````````````````````````````
   ;  Turns on the down direction bit.
   ;
   _Bit1_P0_Dir_Down{1} = 1

   ;```````````````````````````````````````````````````````````````
   ;  Skips this section if hitting the edge.
   ;
   if player0y < _P_Edge_Bottom then goto __Move_Down
   player0y = _P_Edge_Top 
   if _Present_Playfield & $0F < $04 then _Present_Playfield = _Present_Playfield + $01 : _Bit6_New_Playfield{6} = 1 
   ;goto __Next_Playfield bank3
   ;goto __Next_3x3_Playfield bank4      
   goto __Find_Next_Room

   ;```````````````````````````````````````````````````````````````
   ;  Moves player0 down if this is no wall there
   ;
__Move_Down 
   
   player0y = player0y + 1
   if !collision(playfield,player0) then goto __Skip_Joy0_Down
   _Touch_Counter = _Touch_Counter + 1
   ;player0y = player0y - 2 ; hit he wall, reset position

__Skip_Joy0_Down



   ;***************************************************************
   ;
   ;  Joy0 left check.
   ;
   ;```````````````````````````````````````````````````````````````
   ;  Skips this section if joystick isn't moved to the left.
   ;
   if !joy0left then goto __Skip_Joy0_Left

   ;```````````````````````````````````````````````````````````````
   ;  Turns on the left direction bit.
   ;  Remeber the player last direction so it can be reflected horizontally
   ;
    _Bit2_P0_Dir_Left{2} = 1
    _Player0_Reflected_Bit5{5} = 1 

   ;```````````````````````````````````````````````````````````````
   ;  if hitting the edge, get the new screen
   ;
   if player0x > _P_Edge_Left then goto __Move_Left
   player0x = _P_Edge_Right   
   if _Present_Playfield & $F0 > $00 then _Present_Playfield = _Present_Playfield  - $10 : _Bit6_New_Playfield{6} = 1 
   ;goto __Next_Playfield bank3 
   ;goto __Next_3x3_Playfield bank4 
   goto __Find_Next_Room   

__Move_Left
   ;```````````````````````````````````````````````````````````````
   ;  Moves player0 left.
   ;
   player0x = player0x - 1
   if !collision(playfield, player0) then goto __Skip_Joy0_Left
   _Touch_Counter = _Touch_Counter + 1
   ;player0x = player0x + 2 ; Hit a wall, reset position

__Skip_Joy0_Left



   ;***************************************************************
   ;
   ;  Joy0 right check.
   ;
   ;```````````````````````````````````````````````````````````````
   ;  Skips this section if joystick isn't moved to the right.
   ;
   if !joy0right then goto __Skip_Joy0_Right

   ;```````````````````````````````````````````````````````````````
   ;  Turns on the right direction bit.
   ;  set the play reflect to normal
   ;
     _Bit3_P0_Dir_Right{3} = 1
     _Player0_Reflected_Bit5{5} = 0 


   ;```````````````````````````````````````````````````````````````
   ;  if hitting the edge, get the new screen
   ;
   if player0x < _P_Edge_Right then goto __Move_Right
   player0x = _P_Edge_Left 
   if _Present_Playfield & $F0 < $40 then _Present_Playfield = _Present_Playfield  + $10 : _Bit6_New_Playfield{6} = 1 
   ;goto __Next_Playfield bank3
   ;goto __Next_3x3_Playfield bank4     
   goto __Find_Next_Room

   ;```````````````````````````````````````````````````````````````
   ;  Moves player0 right.
   ;  
__Move_Right

  player0x = player0x + 1
  if !collision(playfield, player0) then goto __Skip_Joy0_Right
  _Touch_Counter = _Touch_Counter + 1
  ;player0x = player0x - 2

__Skip_Joy0_Right

__Done_Moving

__Play_Field_Selected




   ;***************************************************************
   ;
   ;  Fire button check.
   ;  Turns on missile0 movement if fire button is pressed and
   ;  missile0 is not moving.
   ;  BUT!!!, you cannot shoot if you have the electric shock shield 
   ;```````````````````````````````````````````````````````````````
   ;  Skips this section if the fire button is not pressed or no weapon
   ;
   if !joy0fire then goto __Skip_Fire
   if _Has_Shockproof_bit5{5} then goto __Skip_Fire
   if !_Has_Bow_Bit2{2} && !_Has_XG7_Bit3{3} then goto __Skip_Fire
  
   ;```````````````````````````````````````````````````````````````
   ;  Skips this section if missile0 is moving or has been fired recently
   ;
   if _Bit7_M0_Moving{7} then goto __Skip_Fire
   if _Shot_Counter then goto __Skip_Fire

   ;```````````````````````````````````````````````````````````````
   ;  Turns on missile0 movement. and stes time interval
   ;
   _Bit7_M0_Moving{7} = 1
   if _Has_XG7_Bit3{3} then _Shot_Counter = 50 else  _Shot_Counter = 200

   ;```````````````````````````````````````````````````````````````
   ;  Takes a 'snapshot' of player0 direction so missile0 will
   ;  stay on track until it hits something.
   ;
   _Bit4_M0_Dir_Up{4} = _Bit0_P0_Dir_Up{0}
   _Bit5_M0_Dir_Down{5} = _Bit1_P0_Dir_Down{1}
   _Bit6_M0_Dir_Left{6} = _Bit2_P0_Dir_Left{2}
   _Bit7_M0_Dir_Right{7} = _Bit3_P0_Dir_Right{3}

   ;```````````````````````````````````````````````````````````````
   ;  Sets up starting position of missile0.
   ;
   missile0x = player0x + 4 : missile0y = player0y-5

   ;```````````````````````````````````````````````````````````````
   ;  Turns on sound effect.
   ;
   if _Ch0_Sound <> 3 then _Ch0_Sound = 2 : _Ch0_Duration = 1 : _Ch0_Counter = 0

__Skip_Fire

   ;```````````````````````````````````````````````````````````````
   ;  Time the shots.
   ;
   if _Shot_Counter then _Shot_Counter = _Shot_Counter - 1

   ;***************************************************************
   ;
   ;  Missile0 movement check.
   ;
   ;```````````````````````````````````````````````````````````````
   ;  Skips this section if missile0 isn't moving.
   ;
   if !_Bit7_M0_Moving{7} then goto __Skip_Missile

   ;```````````````````````````````````````````````````````````````
   ;  Moves missile0 in the appropriate direction.
   ;
   if _Has_Bow_Bit2{2} then temp4 = 1
   if _Has_XG7_Bit3{3} then temp4 = 2
   if _Bit4_M0_Dir_Up{4} then missile0y = missile0y - temp4
   if _Bit5_M0_Dir_Down{5} then missile0y = missile0y + temp4
   if _Bit6_M0_Dir_Left{6} then missile0x = missile0x - temp4
   if _Bit7_M0_Dir_Right{7} then missile0x = missile0x + temp4

   ;```````````````````````````````````````````````````````````````
   ;  Clears missile0 if it hits the edge of the screen.
   ;
   if missile0y < _M_Edge_Top then goto __Delete_Missile
   if missile0y > _M_Edge_Bottom then goto __Delete_Missile
   if missile0x < _M_Edge_Left then goto __Delete_Missile
   if missile0x > _M_Edge_Right then goto __Delete_Missile

   ;```````````````````````````````````````````````````````````````
   ;  Skips rest of section if no collision.
   ;
   if !collision(playfield,missile0) then goto __Skip_Missile

   ;```````````````````````````````````````````````````````````````
   ;  Turns on sound effect.
   ;
   if _Ch0_Sound <> 3 then _Ch0_Sound = 1 : _Ch0_Duration = 1 : _Ch0_Counter = 0

__Delete_Missile

   ;```````````````````````````````````````````````````````````````
   ;  Clears missile0 bit and moves missile0 off the screen.
   ;
   _Bit7_M0_Moving{7} = 0 : missile0x = 200 : missile0y = 200
   
__Skip_Missile



   ;***************************************************************
   ;  Enemy/missile collision check.
   ;```````````````````````````````````````````````````````````````
   ;  Skips section if there is no collision or if no missle is flying
   ;  As it could be the shield that the enemy hit
   if !collision(player1,missile0) then goto __Skip_Shot_Enemy
   if !_Bit7_M0_Moving{7} then goto __Skip_Shot_Enemy

   ;```````````````````````````````````````````````````````````````
   ;  Turns on sound effect.
   ;
   ;_Ch0_Sound = 3 : _Ch0_Duration = 1 : _Ch0_Counter = 0

   ;```````````````````````````````````````````````````````````````
   ;  Clears missile0 bit and moves missile0 off the screen.
   ;
   _Bit7_M0_Moving{7} = 0 : missile0x = 200 : missile0y = 200

   ;```````````````````````````````````````````````````````````````
   ;  Injure or kill the enemy
   ;
   temp4 = _Playfield_Features & %00110000  
   if temp4 <> %00010000 then goto __Not_Nova
   if pfscore1{6} then pfscore1{6} = 0 : goto __Not_Carl 
   if pfscore1{7} then pfscore1{7} = 0 : _Bit0_Nova_Dead{0}=1 : goto __Not_Carl 
   
__Not_Nova
   if temp4 <> %00100000 then goto __Not_Bob
   if pfscore1{3} then pfscore1{3} = 0 : goto __Not_Carl
   if pfscore1{4} then pfscore1{4} = 0 : _Bit1_Bob_Dead{1}=1  : goto __Not_Carl 
   
__Not_Bob
   ; Must be Carl
   if pfscore1{0} then pfscore1{0} = 0 : goto __Not_Carl
   if pfscore1{1} then pfscore1{1} = 0 : _Bit2_Carl_Dead{2} = 1 : goto __Not_Carl
__Not_Carl
 
  ; Injured player gets taken from the board
  goto __Enemy_Injured bank2
__Return_From_Enemy_Injured
 
__Skip_Shot_Enemy



   ;***************************************************************
   ;  Enemy/player collision check.
   ;```````````````````````````````````````````````````````````````
   ;  Check if hit  the Enemy or Key or if the Shield is on
   if !collision(player1,player0) then goto __Did_Not_Touch_Enemy
   if _Display_Key_Bit1{1} then goto __Is_The_Key
   if _Ch0_Sound = 3 then goto __Did_Not_Touch_Enemy
   if _Has_Shield_Bit4{4} then goto __Did_Not_Touch_Enemy
   if _Cash_In_Room_Bit4{4} then goto __Show_Cash bank2
   ;  Hit Enemy Sound
   if _Ch0_Sound <>4 then _Ch0_Sound = 4  : _Ch0_Duration = 1 : _Ch0_Counter = 0 : pfscore2 = pfscore2/2
   if pfscore2 <1 then goto __Player_Death bank2  ; The Player is dead!!!!
   goto __Touched_Enemy

__Is_The_Key
   _Has_Key_Bit0{0} = 1 
   _Display_Key_Bit1{1} = 0 
   ; Hit Object Sound
   if _Ch0_Sound <>3 then _Ch0_Sound = 3 : _Ch0_Duration = 1 : _Ch0_Counter = 0 
   ;_No_Enemy_Present_Bit3[3] = 1 ; This screws it up? Why?
   _Enemy_Info = _Enemy_Info & %00001111 ; Clear all the enemy present bits but leave the Enemy dead bits alone
    player1x = 200 : player1y = 0
 
__Touched_Enemy
__Did_Not_Touch_Enemy

   ;***************************************************************
   ;
   ;  Player to Ball/Station collision check.
   ;
   ;```````````````````````````````````````````````````````````````
   ;  Check is Enemy or Key
   ;
   if !collision(player0,ball) then goto __Skip_Touched_Station
   
   ; Clear the correct station..it on longer has an object in this round
   if _Present_Playfield = $02 then _Station_Filled{0} = 0 : temp6 = 0
   if _Present_Playfield = $12 then _Station_Filled{1} = 0 : temp6 = 1
   if _Present_Playfield = $21 then _Station_Filled{2} = 0 : temp6 = 2
   if _Present_Playfield = $23 then _Station_Filled{3} = 0 : temp6 = 3
   if _Present_Playfield = $31 then _Station_Filled{4} = 0 : temp6 = 4
   if _Present_Playfield = $14 then _Station_Filled{5} = 0 : temp6 = 5
   if _Present_Playfield = $40 then _Station_Filled{6} = 0 : temp6 = 6
   if _Present_Playfield = $44 then _Station_Filled{7} = 0 : temp6 = 7

   ; if wearing the Shockproof cloak, that is removed..only get to use it for one station!
   _Has_Shockproof_bit5{5} = 0
   
   temp4 = _Station_Contents_Pointers&$07 	; the random offset into the station object data array created at the start
   temp3 = temp4 + temp6 				; Offset into Station contents based on the Round data
   
   temp4 = _Round_Number_Bits012 & %00000111 	; Round Number
   if temp4 = 1 then temp5 = _Round_One[temp3] 
   if temp4 = 2 then temp5 = _Round_Two[temp3] 
   if temp4 = 3 then temp5 = _Round_Three[temp3] 
   if temp4 = 4 then temp5 = _Round_Four[temp3]
   if temp4 = 5 then temp5 = _Round_Five[temp3] 
   if temp4 = 6 then temp5 = _Round_Six[temp3]
   if temp4 > 6 then temp5 = _Round_Seven[temp3]

   if temp5 = 0 then pfscore2 = pfscore2*2+1      : goto __Show_Health bank2
   if temp5 = 1 then pfscore2 = pfscore2/2        : goto __Show_Zapped bank2 
   if temp5 = 2 then _Has_Bow_Bit2{2} = 1         : goto __Show_Bow bank2
   if temp5 = 3 then _Has_Code_A_Bit6{6} = 1      : goto __Show_Code_A bank2 
   if temp5 = 4 then _Has_Code_B_Bit7{7} = 1      : goto __Show_Code_B bank2  
   if temp5 = 5 then _Has_XG7_Bit3{3} = 1         : goto __Show_XG7 bank2
   if temp5 = 6 then _Has_Shockproof_bit5{5} = 1  : goto __Show_Invisable bank2
   if temp5 = 7 then _Has_Shield_Bit4{4}= 1       : goto __Show_Shield bank2
   ;if temp5 = 8 then score = score + 10000       : goto __Show_Cash bank2 ; done differently.. like the Key wnegh there are no enemies

__Return_From_Effect
   
   ; if the stations have been cleared in Round 1
   if !_Station_Filled then goto __Next_Round_Effect bank5
   
   ; Sound and clear the ball off the  screen
   _Ch0_Duration = 1 : _Ch0_Counter = 0
   ballx = 200: bally = 200 
   
   
   if temp5 = 5 then goto __Fox_XG7_Touched bank3
   if temp5 = 2 then goto __Fox_Bow_Touched bank3
       
__New_Fox_Sprite

__Skip_Touched_Station


   ;***************************************************************
   ;
   ;  Enemy Movement is 1/2 of th Fox/Player0.
   ;
   ;```````````````````````````````````````````````````````````````
   if _Display_Key_Bit1{1} then goto __Skip_Enemy_Movement ; object displayed, no movement
   if _No_Enemy_Present_Bit3{3} then goto __Skip_Enemy_Movement ; Do move if no enemy
   ;if _Ch1_Duration > 0 then _Ch1_Duration = _Ch1_Duration -1 : goto __Skip_Enemy_Movement ; Enamy shot. delay while recovering

   if _Bit7_M0_Moving{7} then _Bit7_Enemy_Move_Skip{7} = 0  ; Go twice as fast when a shot is fired 
   if _Bit7_Enemy_Move_Skip{7} then _Bit7_Enemy_Move_Skip{7} = 0 : goto __Skip_Enemy_Movement
   _Bit7_Enemy_Move_Skip{7} = 1

   _BitOp_P1_Dir = _BitOp_P1_Dir & %11110000 ; clear the dirction bits 
  

   if !_Bit7_M0_Moving{7} goto __Attack  ; Retreat from a missle No player missle, so attack!!
   if _Bit5_M0_Dir_Down{5}  then _Bit1_P1_Dir_Down{1}  =1 : goto __Retreat 
   if _Bit4_M0_Dir_Up{4}    then _Bit0_P1_Dir_Up{0}    =1 : goto __Retreat 
   if _Bit7_M0_Dir_Right{7} then _Bit3_P1_Dir_Right{3} =1 : goto __Retreat 
   if _Bit6_M0_Dir_Left{6}  then _Bit2_P1_Dir_Left{2}  =1 : goto __Retreat 
   
__Attack
   if player0y < player1y then _Bit0_P1_Dir_Up{0} =1
   if player0y > player1y then _Bit1_P1_Dir_Down{1} =1
   if player0x < player1x then _Bit2_P1_Dir_Left{2} =1 
   if player0x > player1x then _Bit3_P1_Dir_Right{3} =1 
   if player1x > _P_Edge_Right then player1x = _P_Edge_Left ; Player is off the screen!!!! 
__Retreat

   
  goto __Enemy_Animation bank3
__Return_From_Enemy_Animation

   ;***************************************************************
   ;
   ;  Enemy up check.
   ;
   ;```````````````````````````````````````````````````````````````
   ;  Skips this section if enemy isn't moving up.
   ;
   if !_Bit0_P1_Dir_Up{0} then goto __Skip_Enemy_Up

   ;```````````````````````````````````````````````````````````````
   ;  Skips this section if hitting the edge.
   ;
   if player1y < _P_Edge_Top && _Bit7_M0_Moving{7} then goto __Enemy_Escaped bank3
   if player1y < _P_Edge_Top then player1y = _P_Edge_Top : goto __Skip_Enemy_Up

   ;```````````````````````````````````````````````````````````````
   ;  Checks for any playfield pixels that might be in the way.
   ;
   temp5 = (player1x-10)/4
   temp6 = (player1y-9)/8
   if pfread(temp5,temp6) then goto __Skip_Enemy_Up
   temp4 = (player1x-17)/4
   if pfread(temp4,temp6) then goto __Skip_Enemy_Up
   temp3 = temp5 - 1
   if pfread(temp3,temp6) then goto __Skip_Enemy_Up

   ;```````````````````````````````````````````````````````````````
   ;  Moves enemy up.
   ;
   player1y = player1y - 1
 
__Skip_Enemy_Up



   ;***************************************************************
   ;
   ;  Enemy down check.
   ;
   ;```````````````````````````````````````````````````````````````
   ;  Skips this section if enemy isn't moving down.
   ;
   if !_Bit1_P1_Dir_Down{1} then goto __Skip_Enemy_Down

   ;```````````````````````````````````````````````````````````````
   ;  Skips this section if hitting the edge.
   ;
   if player1y > _P_Edge_Bottom && _Bit7_M0_Moving{7} then goto __Enemy_Escaped bank3
   if player1y > _P_Edge_Bottom then player1y = _P_Edge_Bottom : goto __Skip_Enemy_Down

   ;```````````````````````````````````````````````````````````````
   ;  Stops movement if a playfield pixel is in the way.
   ;
   temp5 = (player1x-10)/4
   temp6 = (player1y)/8
   if pfread(temp5,temp6) then goto __Skip_Enemy_Down
   temp4 = (player1x-17)/4
   if pfread(temp4,temp6) then goto __Skip_Enemy_Down
   temp3 = temp5 - 1
   if pfread(temp3,temp6) then goto __Skip_Enemy_Down

   ;```````````````````````````````````````````````````````````````
   ;  Moves enemy down.
   ;
   player1y = player1y + 1
 
__Skip_Enemy_Down



   ;***************************************************************
   ;
   ;  Enemy left check.
   ;
   ;```````````````````````````````````````````````````````````````
   ;  Skips this section if enemy isn't moving left.
   ;
   if !_Bit2_P1_Dir_Left{2} then goto __Skip_Enemy_Left

   ;```````````````````````````````````````````````````````````````
   ;  Let the enemy run off screen to avoid being hit.
   ;
   if player1x < _P_Edge_Left && _Bit7_M0_Moving{7} then goto __Enemy_Escaped bank3
   if player1x < _P_Edge_Left then player1x = _P_Edge_Left : goto __Skip_Enemy_Left

   ;```````````````````````````````````````````````````````````````
   ;  Stops movement if a playfield pixel is in the way.
   ;
   temp5 = (player1y-1)/8
   temp6 = (player1x-18)/4
   if pfread(temp6,temp5) then goto __Skip_Enemy_Left
   temp3 = (player1y-8)/8
   if pfread(temp6,temp3) then goto __Skip_Enemy_Left

   ;```````````````````````````````````````````````````````````````
   ;  Moves enemy left.
   ;
   player1x = player1x - 1
   _Bit5_P1_Reflected{5} =1
  
__Skip_Enemy_Left



   ;***************************************************************
   ;
   ;  Enemy right check.
   ;
   ;```````````````````````````````````````````````````````````````
   ;  Skips this section if enemy isn't moving right.
   ;
   if !_Bit3_P1_Dir_Right{3} then goto __Skip_Enemy_Right

   ;```````````````````````````````````````````````````````````````
   ;  Let the enemy runn off screen to avoid being hit.
   ;
   if player1x > _P_Edge_Right && _Bit7_M0_Moving{7} then goto __Enemy_Escaped bank3 
   if player1x > _P_Edge_Right then player1x = _P_Edge_Right : goto __Skip_Enemy_Right

   ;```````````````````````````````````````````````````````````````
   ;  Stops movement if a playfield pixel is in the way.
   ;
   temp5 = (player1y-1)/8
   temp6 = (player1x-9)/4
   if pfread(temp6,temp5) then goto __Skip_Enemy_Right
   temp3 = (player1y-8)/8
   if pfread(temp6,temp3) then goto __Skip_Enemy_Right

   ;```````````````````````````````````````````````````````````````
   ;  Moves enemy right.
   ;
   player1x = player1x + 1
   _Bit5_P1_Reflected{5} =0
 
__Skip_Enemy_Right



__Skip_Enemy_Movement

   ;***************************************************************
   ;
   ;  Code continues in next bank.
   ;
   goto __Code_Section_2 bank2


__Find_Next_Room
  temp4 = _Round_Number_Bits012 & %00000111 ;  Find out the round number
  if temp4 < 3 then goto __Next_3x3_Playfield bank4
  if temp4 < 5 then goto __Next_4x4_Playfield bank4
  goto __Next_5x5_Playfield bank3

   ;,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
   ;```````````````````````````````````````````````````````````````
   bank 2
   ;,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
   ;```````````````````````````````````````````````````````````````
 
__Code_Section_2

   if player0y > _P_Edge_Bottom then goto __Back_To_Square_One
   if player0y < _P_Edge_Top    then goto __Back_To_Square_One
   if player0x > _P_Edge_Right  then goto __Back_To_Square_One 
   if player0x < _P_Edge_Left   then goto __Back_To_Square_One

   ;***************************************************************
   ;
   ;  Channel 0 sound effect check.
   ;
   ;```````````````````````````````````````````````````````````````
   ;  Skips all channel 0 sounds if sounds are off.
   ;
   if !_Ch0_Sound then goto __Skip_Ch_0

   ;```````````````````````````````````````````````````````````````
   ;  Decreases the channel 0 duration counter.
   ;
   _Ch0_Duration = _Ch0_Duration - 1

   ;```````````````````````````````````````````````````````````````
   ;  Skips all channel 0 sounds if duration counter is greater
   ;  than zero
   ;
   if _Ch0_Duration then goto __Skip_Ch_0



   ;***************************************************************
   ;
   ;  Channel 0 sound effect 001.
   ;
   ;  Up sound effect.
   ;
   ;```````````````````````````````````````````````````````````````
   ;  Skips this section if sound 001 isn't on.
   ;
   if _Ch0_Sound <> 1 then goto __Skip_Ch0_Sound_001

   ;```````````````````````````````````````````````````````````````
   ;  Retrieves first part of channel 0 data.
   ;
   temp4 = _SD_Shot_Wall[_Ch0_Counter]

   ;```````````````````````````````````````````````````````````````
   ;  Checks for end of data.
   ;
   if temp4 = 255 then goto __Clear_Ch_0

   ;```````````````````````````````````````````````````````````````
   ;  Retrieves more channel 0 data.
   ;
   _Ch0_Counter = _Ch0_Counter + 1
   temp5 = _SD_Shot_Wall[_Ch0_Counter] : _Ch0_Counter = _Ch0_Counter + 1
   temp6 = _SD_Shot_Wall[_Ch0_Counter] : _Ch0_Counter = _Ch0_Counter + 1

   ;```````````````````````````````````````````````````````````````
   ;  Plays channel 0.
   ;
   AUDV0 = temp4
   AUDC0 = temp5
   AUDF0 = temp6

   ;```````````````````````````````````````````````````````````````
   ;  Sets Duration.
   ;
   _Ch0_Duration = _SD_Shot_Wall[_Ch0_Counter] : _Ch0_Counter = _Ch0_Counter + 1

   ;```````````````````````````````````````````````````````````````
   ;  Jumps to end of channel 0 area.
   ;
   goto __Skip_Ch_0

__Skip_Ch0_Sound_001



   ;***************************************************************
   ;
   ;  Channel 0 sound effect 002.
   ;
   ;  Shoot missile sound effect.
   ;
   ;```````````````````````````````````````````````````````````````
   ;  Skips this section if sound 002 isn't on.
   ;
   if _Ch0_Sound <> 2 then goto __Skip_Ch0_Sound_002

   ;```````````````````````````````````````````````````````````````
   ;  Retrieves first part of channel 0 data.
   ;
   temp4 = _SD_Shoot_Miss[_Ch0_Counter]

   ;```````````````````````````````````````````````````````````````
   ;  Checks for end of data.
   ;
   if temp4 = 255 then goto __Clear_Ch_0

   ;```````````````````````````````````````````````````````````````
   ;  Retrieves more channel 0 data.
   ;
   _Ch0_Counter = _Ch0_Counter + 1
   temp5 = _SD_Shoot_Miss[_Ch0_Counter] : _Ch0_Counter = _Ch0_Counter + 1
   temp6 = _SD_Shoot_Miss[_Ch0_Counter] : _Ch0_Counter = _Ch0_Counter + 1

   ;```````````````````````````````````````````````````````````````
   ;  Plays channel 0.
   ;
   AUDV0 = temp4
   AUDC0 = temp5
   AUDF0 = temp6

   ;```````````````````````````````````````````````````````````````
   ;  Sets Duration.
   ;
   _Ch0_Duration = _SD_Shoot_Miss[_Ch0_Counter] : _Ch0_Counter = _Ch0_Counter + 1

   ;```````````````````````````````````````````````````````````````
   ;  Jumps to end of channel 0 area.
   ;
   goto __Skip_Ch_0

__Skip_Ch0_Sound_002



   ;***************************************************************
   ;
   ;  Channel 0 sound effect 003.
   ;
   ;  Shoot enemy.
   ;
   ;```````````````````````````````````````````````````````````````
   ;  Skips this section if sound 003 isn't on.
   ;
   if _Ch0_Sound <> 3 then goto __Skip_Ch0_Sound_003

   ;```````````````````````````````````````````````````````````````
   ;  Retrieves first part of channel 0 data.
   ;
   temp4 = _SD_Touch_Object[_Ch0_Counter]

   ;```````````````````````````````````````````````````````````````
   ;  Checks for end of data.
   ;
   if temp4 = 255 then goto __Clear_Ch_0

   ;```````````````````````````````````````````````````````````````
   ;  Retrieves more channel 0 data.
   ;
   _Ch0_Counter = _Ch0_Counter + 1
   temp5 = _SD_Touch_Object[_Ch0_Counter] : _Ch0_Counter = _Ch0_Counter + 1
   temp6 = _SD_Touch_Object[_Ch0_Counter] : _Ch0_Counter = _Ch0_Counter + 1
  

   ;```````````````````````````````````````````````````````````````
   ;  Plays channel 0.
   ;
   AUDV0 = temp4
   AUDC0 = temp5
   AUDF0 = temp6

   ;```````````````````````````````````````````````````````````````
   ;  Sets Duration.
   ;
   _Ch0_Duration = _SD_Touch_Object[_Ch0_Counter] : _Ch0_Counter = _Ch0_Counter + 1

   ;```````````````````````````````````````````````````````````````
   ;  Jumps to end of channel 0 area.
   ;
   goto __Skip_Ch_0

__Skip_Ch0_Sound_003



   ;***************************************************************
   ;
   ;  Channel 0 sound effect 004.
   ;
   ;  Touch enemy.
   ;
   ;```````````````````````````````````````````````````````````````
   ;  Skips this section if sound 004 isn't on.
   ;
   if _Ch0_Sound <> 4 then goto __Skip_Ch0_Sound_004

   ;```````````````````````````````````````````````````````````````
   ;  Retrieves first part of channel 0 data.
   ;
   temp4 = _SD_Touch_Enemy[_Ch0_Counter]

   ;```````````````````````````````````````````````````````````````
   ;  Checks for end of data.
   ;
   if temp4 = 255 then goto __Clear_Ch_0

   ;```````````````````````````````````````````````````````````````
   ;  Retrieves more channel 0 data.
   ;
   _Ch0_Counter = _Ch0_Counter + 1
   temp5 = _SD_Touch_Enemy[_Ch0_Counter] : _Ch0_Counter = _Ch0_Counter + 1
   temp6 = _SD_Touch_Enemy[_Ch0_Counter] : _Ch0_Counter = _Ch0_Counter + 1
   
   ; Color cycle player
   temp3 = _Ch0_Counter + $40
   COLUP0 = temp3

   ;```````````````````````````````````````````````````````````````
   ;  Plays channel 0.
   ;
   AUDV0 = temp4
   AUDC0 = temp5
   AUDF0 = temp6

   ;```````````````````````````````````````````````````````````````
   ;  Sets Duration.
   ;
   _Ch0_Duration = _SD_Touch_Enemy[_Ch0_Counter] : _Ch0_Counter = _Ch0_Counter + 1

   ;```````````````````````````````````````````````````````````````
   ;  Jumps to end of channel 0 area.
   ;
   goto __Skip_Ch_0

__Skip_Ch0_Sound_004


   ;***************************************************************
   ;
   ;  Channel 0 sound effect 005.
   ;
   ;  Walking.
   ;
   ;```````````````````````````````````````````````````````````````
   ;  Skips this section if sound 004 isn't on.
   ;
   if _Ch0_Sound <> 5 then goto __Skip_Ch0_Sound_005

   ;```````````````````````````````````````````````````````````````
   ;  Retrieves first part of channel 0 data.
   ;
   temp4 = _SD_Walk[_Ch0_Counter]

   ;```````````````````````````````````````````````````````````````
   ;  Checks for end of data.
   ;
   if temp4 = 255 then goto __Clear_Ch_0

   ;```````````````````````````````````````````````````````````````
   ;  Retrieves more channel 0 data.
   ;
   _Ch0_Counter = _Ch0_Counter + 1
   temp5 = _SD_Walk[_Ch0_Counter] : _Ch0_Counter = _Ch0_Counter + 1
   temp6 = _SD_Walk[_Ch0_Counter] : _Ch0_Counter = _Ch0_Counter + 1

   ;```````````````````````````````````````````````````````````````
   ;  Plays channel 0.
   ;
   AUDV0 = temp4
   AUDC0 = temp5
   AUDF0 = temp6

   ;```````````````````````````````````````````````````````````````
   ;  Sets Duration.
   ;
   _Ch0_Duration = _SD_Walk[_Ch0_Counter] : _Ch0_Counter = _Ch0_Counter + 1

   ;```````````````````````````````````````````````````````````````
   ;  Jumps to end of channel 0 area.
   ;
   goto __Skip_Ch_0

__Skip_Ch0_Sound_005


 
   ;***************************************************************
   ;
   ;  Jumps to end of channel 0 area. (This catches any mistakes.)
   ;
   goto __Skip_Ch_0



   ;***************************************************************
   ;
   ;  Clears channel 0.
   ;
__Clear_Ch_0
   
   _Ch0_Sound = 0 : AUDV0 = 0



   ;***************************************************************
   ;
   ;  End of channel 0 area.
   ;
__Skip_Ch_0

__Skip_Ch_1

__Skip_To_End_Of_Program



   ;***************************************************************
   ;
   ;  Displays the screen.
   ;
   drawscreen



   ;***************************************************************
   ;
   ;  Reset switch check and end of main loop.
   ;
   ;  Any Atari 2600 program should restart when the reset  
   ;  switch is pressed. It is part of the usual standards
   ;  and procedures.
   ;
   ;```````````````````````````````````````````````````````````````
   ;  Turns off reset restrainer bit and jumps to beginning of
   ;  main loop if the reset switch is not pressed.
   ;
   if !switchreset then _Bit0_Reset_Restrainer{0} = 0 : goto __Main_Loop bank1

   ;```````````````````````````````````````````````````````````````
   ;  Jumps to beginning of main loop if the reset switch hasn't
   ;  been released after being pressed.
   ;
   if _Bit0_Reset_Restrainer{0} then goto __Main_Loop bank1

   ;```````````````````````````````````````````````````````````````
   ;  Restarts the program.
   ;
   goto __Start_Restart bank1

   
 
   ;```````````````````````````````````````````````````````````````
   ; Effects Section.
   ;


   ;*****************************************
   ;  Effect: Bow and Arrows found. 
__Show_Bow
 
Bow_Arrows
 player0:
 %00110000
 %00011000
 %00001100
 %00001100
 %00001100
 %00001100
 %00011000
 %00110000
end

   data _SD_Touch_Bow
   12,4,23
   4
   10,4,29
   4
   8,4,23
   4
   6,4,29
   4
   4,4,23
   4
   3,4,29
   4
   2,4,23
   1
   1,4,29
   1
   255
end

   _Ch0_Counter = 0 : AUDV0 = 0 : AUDV1 = 0:  bally = 0

__Stay_In_Bow

   ; Check to see if this is he end of the sound data, if so we're done, clean up and return   
   temp4 = _SD_Touch_Bow[_Ch0_Counter]
   if temp4 = 255 then _Ch0_Counter = 0: _Ch0_Sound = 0 : AUDV0 = 0 : goto __Return_From_Effect bank1
   ; if not done, we have the Volume, get the Tone Color and Frequency
   _Ch0_Counter = _Ch0_Counter + 1
   temp5 = _SD_Touch_Bow[_Ch0_Counter] : _Ch0_Counter = _Ch0_Counter + 1
   temp6 = _SD_Touch_Bow[_Ch0_Counter] : _Ch0_Counter = _Ch0_Counter + 1
   AUDV0 = temp4
   AUDC0 = temp5
   AUDF0 = temp6
   ; Get the tone duration
   _Ch0_Duration = _SD_Touch_Bow[_Ch0_Counter] : _Ch0_Counter = _Ch0_Counter + 1

__Playing_Bow_Sound   

   COLUP0 = $F6
   drawscreen
   ; Are we done playing the tone?, if not, decrament the time and keep playing, if yes, get next tone
   _Ch0_Duration = _Ch0_Duration -1
   if _Ch0_Duration then goto __Playing_Bow_Sound   
   goto __Stay_In_Bow


   ;*****************************************
   ;  Effect: XG7 laser Rifle found. 
__Show_XG7

Laser_Rifle
 player0:
 %00000000
 %00000000
 %11000000
 %11101000
 %11111110
 %00100000
 %01110000
 %00000000
end

   data _SD_Touch_XG7
   12,4,23
   4
   10,4,29
   4
   8,4,23
   4
   6,4,29
   4
   4,4,23
   4
   3,4,29
   4
   2,4,23
   1
   1,4,29
   1
   255
end

   _Ch0_Counter = 0 : AUDV0 = 0 : AUDV1 = 0:  bally = 0

__Stay_In_XG7

   ; Check to see if this is he end of the sound data, if so we're done, clean up and return   
   temp4 = _SD_Touch_XG7[_Ch0_Counter]
   if temp4 = 255 then _Ch0_Counter = 0: _Ch0_Sound = 0 : AUDV0 = 0 : goto __Return_From_Effect bank1
   ; if not done, we have the Volume, get the Tone Color and Frequency
   _Ch0_Counter = _Ch0_Counter + 1
   temp5 = _SD_Touch_XG7[_Ch0_Counter] : _Ch0_Counter = _Ch0_Counter + 1
   temp6 = _SD_Touch_XG7[_Ch0_Counter] : _Ch0_Counter = _Ch0_Counter + 1
   AUDV0 = temp4
   AUDC0 = temp5
   AUDF0 = temp6
   ; Get the tone duration
   _Ch0_Duration = _SD_Touch_XG7[_Ch0_Counter] : _Ch0_Counter = _Ch0_Counter + 1

__Playing_XG7_Sound   

   COLUP0 = $06
   drawscreen
   ; Are we done playing the tone?, if not, decrament the time and keep playing, if yes, get next tone
   _Ch0_Duration = _Ch0_Duration -1
   if _Ch0_Duration then goto __Playing_XG7_Sound   
   goto __Stay_In_XG7


 
   ;*****************************************
   ;  Effect: Health found. 
__Show_Health
 
 player0:
 %11111110
 %11101110
 %11000110
 %11101110
 %11111110
 %01000100
 %01111100
 %00000000
end

   data _SD_Touch_Health
   12,4,23
   4
   10,4,29
   4
   8,4,23
   4
   6,4,29
   4
   4,4,23
   4
   3,4,29
   4
   2,4,23
   1
   1,4,29
   1
   255
end

   _Ch0_Counter = 0 : AUDV0 = 0 : AUDV1 = 0:  bally = 0

__Stay_In_Health

   ; Check to see if this is he end of the sound data, if so we're done, clean up and return   
   temp4 = _SD_Touch_Health[_Ch0_Counter]
   if temp4 = 255 then _Ch0_Counter = 0: _Ch0_Sound = 0 : AUDV0 = 0 : goto __Return_From_Effect bank1
   ; if not done, we have the Volume, get the Tone Color and Frequency
   _Ch0_Counter = _Ch0_Counter + 1
   temp5 = _SD_Touch_Health[_Ch0_Counter] : _Ch0_Counter = _Ch0_Counter + 1
   temp6 = _SD_Touch_Health[_Ch0_Counter] : _Ch0_Counter = _Ch0_Counter + 1
   AUDV0 = temp4
   AUDC0 = temp5
   AUDF0 = temp6
   ; Get the tone duration
   _Ch0_Duration = _SD_Touch_Health[_Ch0_Counter] : _Ch0_Counter = _Ch0_Counter + 1

__Playing_Health_Sound   

   COLUP0 = $46
   drawscreen
   ; Are we done playing the tone?, if not, decrament the time and keep playing, if yes, get next tone
   _Ch0_Duration = _Ch0_Duration -1
   if _Ch0_Duration then goto __Playing_Health_Sound   
   goto __Stay_In_Health


   ;*****************************************
   ;  Effect: Got Zapped!!!. 
__Show_Zapped

 player0:
 %00000000
 %10000010
 %01010100
 %00101000
 %01000100
 %00101000
 %01010100
 %10000010
end 
 

   data _SD_Touch_Zapped
   12,8,1
   4
   10,8,2
   4
   8,8,3
   4
   6,8,4
   4
   4,8,3
   4
   3,8,2
   4
   2,8,1
   1
   1,8,0
   1
   255
end

   _Ch0_Counter = 0 : AUDV0 = 0 : AUDV1 = 0:  bally = 0

__Stay_In_Zapped

   ; Check to see if this is he end of the sound data, if so we're done, clean up and return   
   temp4 = _SD_Touch_Zapped[_Ch0_Counter]
   if temp4 = 255 then _Ch0_Counter = 0: _Ch0_Sound = 0 : AUDV0 = 0 : goto __Return_From_Effect bank1
   ; if not done, we have the Volume, get the Tone Color and Frequency
   _Ch0_Counter = _Ch0_Counter + 1
   temp5 = _SD_Touch_Zapped[_Ch0_Counter] : _Ch0_Counter = _Ch0_Counter + 1
   temp6 = _SD_Touch_Zapped[_Ch0_Counter] : _Ch0_Counter = _Ch0_Counter + 1
   AUDV0 = temp4
   AUDC0 = temp5
   AUDF0 = temp6
   ; Get the tone duration
   _Ch0_Duration = _SD_Touch_Zapped[_Ch0_Counter] : _Ch0_Counter = _Ch0_Counter + 1

__Playing_Zapped_Sound   

   COLUP0 = $12 + _Ch0_Duration 
   drawscreen
   ; Are we done playing the tone?, if not, decrament the time and keep playing, if yes, get next tone
   _Ch0_Duration = _Ch0_Duration -1
   if _Ch0_Duration then goto __Playing_Zapped_Sound   
   goto __Stay_In_Zapped


   ;*****************************************
   ;  Effect: Shockproof found. 
__Show_Invisable
 
Invisable
 player0:
 %01101011
 %01101011
 %01100111
 %01100001
 %01100111
 %01110011
 %01110011
 %00111110
end

   data _SD_Touch_Invisable
   12,4,23
   4
   10,4,29
   4
   8,4,23
   4
   6,4,29
   4
   4,4,23
   4
   3,4,29
   4
   2,4,23
   1
   1,4,29
   1
   255
end

   _Ch0_Counter = 0 : AUDV0 = 0 : AUDV1 = 0:  bally = 0

__Stay_In_Invisable

   ; Check to see if this is he end of the sound data, if so we're done, clean up and return   
   temp4 = _SD_Touch_Invisable[_Ch0_Counter]
   if temp4 = 255 then _Ch0_Counter = 0: _Ch0_Sound = 0 : AUDV0 = 0 : goto __Return_From_Effect bank1
   ; if not done, we have the Volume, get the Tone Color and Frequency
   _Ch0_Counter = _Ch0_Counter + 1
   temp5 = _SD_Touch_Invisable[_Ch0_Counter] : _Ch0_Counter = _Ch0_Counter + 1
   temp6 = _SD_Touch_Invisable[_Ch0_Counter] : _Ch0_Counter = _Ch0_Counter + 1
   AUDV0 = temp4
   AUDC0 = temp5
   AUDF0 = temp6
   ; Get the tone duration
   _Ch0_Duration = _SD_Touch_Invisable[_Ch0_Counter] : _Ch0_Counter = _Ch0_Counter + 1

__Playing_Invisable_Sound   

   COLUP0 = $46
   drawscreen
   ; Are we done playing the tone?, if not, decrament the time and keep playing, if yes, get next tone
   _Ch0_Duration = _Ch0_Duration -1
   if _Ch0_Duration then goto __Playing_Invisable_Sound   
   goto __Stay_In_Invisable


   ;*****************************************
   ;  Effect: Health found. 
__Show_Shield

Shield
 player0:
 %00111000
 %01111100
 %01111100
 %11101110
 %11010110
 %11101110
 %11111110
 %01111100
end 

   data _SD_Touch_Shield
   12,4,23
   4
   10,4,29
   4
   8,4,23
   4
   6,4,29
   4
   4,4,23
   4
   3,4,29
   4
   2,4,23
   1
   1,4,29
   1
   255
end

   _Ch0_Counter = 0 : AUDV0 = 0 : AUDV1 = 0:  bally = 0

__Stay_In_Shield

   ; Check to see if this is he end of the sound data, if so we're done, clean up and return   
   temp4 = _SD_Touch_Shield[_Ch0_Counter]
   if temp4 = 255 then _Ch0_Counter = 0: _Ch0_Sound = 0 : AUDV0 = 0 : goto __Return_From_Effect bank1
   ; if not done, we have the Volume, get the Tone Color and Frequency
   _Ch0_Counter = _Ch0_Counter + 1
   temp5 = _SD_Touch_Shield[_Ch0_Counter] : _Ch0_Counter = _Ch0_Counter + 1
   temp6 = _SD_Touch_Shield[_Ch0_Counter] : _Ch0_Counter = _Ch0_Counter + 1
   AUDV0 = temp4
   AUDC0 = temp5
   AUDF0 = temp6
   ; Get the tone duration
   _Ch0_Duration = _SD_Touch_Shield[_Ch0_Counter] : _Ch0_Counter = _Ch0_Counter + 1

__Playing_Shield_Sound   

   COLUP0 = $46
   drawscreen
   ; Are we done playing the tone?, if not, decrament the time and keep playing, if yes, get next tone
   _Ch0_Duration = _Ch0_Duration -1
   if _Ch0_Duration then goto __Playing_Shield_Sound   
   goto __Stay_In_Shield


   ;*****************************************
   ;  Effect: Cash found. 
__Show_Cash
 
   data _SD_Touch_Cash
   12,4,23
   4
   0,0,29
   4
   8,4,23
   4
   6,4,23
   1
   4,4,23
   1
   3,4,23
   1
   2,4,23
   1
   1,4,23
   1
   255
end

   _Ch0_Counter = 0 : AUDV0 = 0 : AUDV1 = 0:  bally = 0
   score = score + 10000 ; Collect the Dough!!!

__Stay_In_Cash

   ; Check to see if this is he end of the sound data, if so we're done, clean up and return   
   temp4 = _SD_Touch_Cash[_Ch0_Counter]
   if temp4 = 255 then _Ch0_Counter = 0: _Ch0_Sound = 0 : AUDV0 = 0 : player1x = 0: player1y = 0: goto __Return_From_Effect bank1
   ; if not done, we have the Volume, get the Tone Color and Frequency
   _Ch0_Counter = _Ch0_Counter + 1
   temp5 = _SD_Touch_Cash[_Ch0_Counter] : _Ch0_Counter = _Ch0_Counter + 1
   temp6 = _SD_Touch_Cash[_Ch0_Counter] : _Ch0_Counter = _Ch0_Counter + 1
   AUDV0 = temp4
   AUDC0 = temp5
   AUDF0 = temp6
   ; Get the tone duration
   _Ch0_Duration = _SD_Touch_Cash[_Ch0_Counter] : _Ch0_Counter = _Ch0_Counter + 1

__Playing_Cash_Sound   

   COLUP0 = $96
   drawscreen
   ; Are we done playing the tone?, if not, decrament the time and keep playing, if yes, get next tone
   _Ch0_Duration = _Ch0_Duration -1
   if _Ch0_Duration then goto __Playing_Cash_Sound   
   goto __Stay_In_Cash




   ;*****************************************
   ;  Effect:  Code A found. 
   ;  Code A moves to the player
__Show_Code_A 
    player1:
    %00111110
    %01101100
    %01010100
    %01101110
    %01111110
    %01100100
    %01100100
    %00111110
end
    player1x = 20 : player1y = 20 
    
    for _Ch0_Counter = 1 to 200 step 1
    COLUPF = $04
    COLUP1 = _Ch0_Counter
    temp4 = _Ch0_Counter&1
    temp5 = _Ch0_Counter&7 + 5
    if temp4 then goto __No_Movement
    if player0x > player1x then player1x = player1x+1
    if player0x < player1x then player1x = player1x-1
    if player0y > player1y then player1y = player1y+1
    if player0y < player1y then player1y = player1y-1
    AUDV1 = 6
    AUDC1 = temp5
    AUDF1 = 15
__No_Movement
    drawscreen
    next
    ;  Done with effect, blank the enemy, stop the sound and return
    player1:
    %00000000
    %00000000
    %00000000
    %00000000
    %00000000
    %00000000
    %00000000
    %00000000
end
    AUDV1 = 0
    AUDC1 = 0
    AUDF1 = 0
    ;_No_Enemy_Present_Bit3[3] = 1 ; This screws it up? Why?
    _Enemy_Info = _Enemy_Info & %00001111 ; Clear all the enemy present bits but leave the Enemy dead bits alone
    player1x = 200 : player1y = 0


    goto __Return_From_Effect bank1


 ;*****************************************
 ;  Effect:  Code B found. 
 ;  Code A and B come together
 ;  The game ends and the enemys blow up
__Show_Code_B 
 
 player0:
 %00111110
 %01101100
 %01010100
 %01101110
 %01111110
 %01100100
 %01100100
 %00111110
end

 player1:
 %00111100
 %01111110
 %01110110
 %00101010
 %00111110
 %01100110
 %01100110
 %00111100
end   
   
    player0x = 20 : player0y = 44
    player1x = 140 : player1y = 44  
    
    for _Ch0_Counter = 1 to 235 step 1
    COLUPF = $00
    COLUP0 = $AE
    COLUP1 = $AE
    temp4 = _Ch0_Counter&3
    if temp4 then goto __No_Movement_B
    player0x = player0x+1
    player1x = player1x-1
    AUDV1 = 6
    AUDC1 = 15
    AUDF1 = _Ch0_Counter/16
__No_Movement_B
    drawscreen
    next ; jump back to loop

    player0x = 82 : player0y = 50
    player1x = 83 : player1y = 56  
   ; Explosion
   player0:
   %00000001
   %01000100
   %00010000
   %10001010
   %00101000
   %00000101
   %01010000
   %00000100
   
end
   player1:
   %01101100
   %00101000
   %00111000
   %10111010
   %01111100
   %00010000
   %00010000
   %00000000
   %00000000
   %00000000
   %00000000
   %00000000
end  
    
    ; Heads Explode Scene
    _Ch0_Counter = 1

__Loop_Back_Explode
    _Ch0_Counter = _Ch0_Counter +1
    if _Ch0_Counter = 240 then goto __END_OF_GAME
    
    NUSIZ0 = $13 ; 3 players
    NUSIZ1 = $13 ; 3 explotions
    COLUPF = $00
    COLUP0 = _Ch0_Counter&15 + $40 ; reds 
    COLUP1 = $08
        
    temp4 = rand&1
    REFP0 = $08
    if temp4 then REFP0 = $00
    temp4 = _Ch0_Counter&3
    if temp4 then goto __Slow_Death
    AUDV1 = 8
    AUDC1 = 3
    AUDF1 = 26
    AUDV0 = 8
    AUDC0 = 8
    AUDF0 = _Ch0_Counter&31

__Slow_Death
    
    drawscreen
    goto __Loop_Back_Explode ; jump back to loop

__END_OF_GAME
    COLUPF = $96
    COLUP0 = $00
    COLUP1 = $42
    AUDV0 = 0
    AUDC0 = 0
    AUDF0 = 0

    AUDV1 = 0
    AUDC1 = 0
    AUDF1 = 0
 playfield:
 .XXX..X.........X...............
 X....X.X.XXXX..X................
 X.XX.XXX.X.X.X.XX...............
 .XXX.X.X.X.X.X.X................
 .......X.......XX...............
 .......X........................
 .XX.......X.....................
 XX.X.X.X.X...X..................
 X..X.X.X.XX.X...................
 X.XX.XXX.X..X...................
 .XX...X..XX.X...................
end
    var30 = %10101111
    drawscreen
    NUSIZ0 = $13 ; 2 pixel wide missle 0
    NUSIZ1 = $13 ; 2 pixel hie missle 1
    
   ;  Deal with the rest game function
   if !switchreset then _Bit0_Reset_Restrainer{0} = 0 : goto __END_OF_GAME
   if _Bit0_Reset_Restrainer{0} then goto __END_OF_GAME
   goto __Start_Restart bank1


   ;********************************************
   ;  Effect: Player touch the wall too long!!!
__Zapped
   _Animation_Counter = _Animation_Counter + 1
   temp3 = rand&15
   COLUPF = $10 + temp3
   AUDV0 = 8 : AUDC0 = 3 : AUDF0 = 1
   if _Player0_Reflected_Bit5{5} then REFP0 = $08 else REFP0 = $00
   
   score = score - 100
   scorecolor = $10 + temp3

   drawscreen
   
   if !collision(playfield,player0) then __Skip_Zapped_Fix
   if _Bit0_P0_Dir_Up{0} then player0y = player0y +1 ; goto __Skip_Zapped_Fix
   if _Bit1_P0_Dir_Down{1} then player0y = player0y -1 ; goto __Skip_Zapped_Fix
   if _Bit2_P0_Dir_Left{2} then player0x = player0x +1 ; goto __Skip_Zapped_Fix
   if _Bit3_P0_Dir_Right{3} then player0x = player0x -1 ; goto __Skip_Zapped_Fix
__Skip_Zapped_Fix
   if _Animation_Counter <20 then goto __Zapped 
   
   ; Done being zapped, kill sound, freese the character, reset colors and return
   AUDV0 = 0 
   _Animation_Counter = 0
   _Frozen = 50  : _Shot_Counter = 50 ;  Freeze the character for a while, cannot move ot shoot
   scorecolor = $C4
   ; if the player gets Zapped out of the arena, they are dead!!
   if player0x > _P_Edge_Right  then goto __Back_To_Square_One bank2
   if player0x < _P_Edge_Left   then goto __Back_To_Square_One bank2
   if player0y < _P_Edge_Top    then goto __Back_To_Square_One bank2
   if player0y > _P_Edge_Bottom then goto __Back_To_Square_One bank2

   goto __Skip_Collision_Fix bank1


   ;*****************************************
   ;  Effect:  Player is retrun to the starting point

__Back_To_Square_One
  
   player0x = _P_Edge_Right : player0y = _P_Edge_Bottom
   _No_Enemy_Present_Bit3{3} =1 : player1x = 200 : player1y = 0
   
   _Present_Playfield  = $00
   _Playfield_Features = %00000000
 playfield:
 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
 XX......XX.....................X
 X...............................
 X...............................
 XX......XX......................
 XXXXXXXXXX......................
 X...............................
 X...............................
 X...............................
 X...............................
 XX.............................X
end
__Returning_Player_To_Start
  player0x = player0x -1 : if player0x = 35 then AUDV0 = 0 : goto  __Skip_Collision_Fix bank1
  player0y = player0y -1 : if player0y < 28 then player0y =28
  COLUP0 = player0x
  AUDF0 = player0y & $1F : AUDC0 = 3 : AUDV0 = 8 ; Rising sound like the hunter injured lift	
  
  drawscreen
  goto __Returning_Player_To_Start bank2






   ;*****************************************
   ;  Effect:  Pleyer is dead
  
__Player_Death

 player1x = 110 : player1y = 50 
 player0x = 107 : player0y = 43

 
 ;dead guy   
 player1:
 %01110111
 %01110111
 %00110110
 %00110110
 %01111111
 %01111111
 %01101011
 %01000001
 %01101011
 %00111110
 %00011100
 %00011100
 %00111110
 %01111111
 %01011101
 %01100011
 %01111111
 %01101011
 %00111110
 %00000000
end

 ;explosion
 player0:
 %00000001
 %01000100
 %00010000
 %10001010
 %00101000
 %00000101
 %01010000
 %00000100
end
   playfield:
   .XXX..X.........X...............
   X....X.X.XXXX..X................
   X.XX.XXX.X.X.X.XX...............
   .XXX.X.X.X.X.X.X................
   .......X.......XX...............
   ................................
   .XX.......X.....................
   XX.X.X.X.X...X..................
   X..X.X.X.XX.X...................
   X.XX.XXX.X..X...................
   .XX...X..XX.X...................
end
  
  ; Setup the dying sound
  _Ch0_Counter = 2 
  _Ch0_Duration= 6 
  AUDV0 = 3
  AUDV1 = 1

__Player_Dying
   
   ; Display the rouond number that you died in
   ;var30 = %01010101
   ;temp4 = _Round_Number_Bits012 & %00000111
   ;if temp4 = 1 then var34 = %00000001
   ;if temp4 = 2 then var34 = %00000011
   ;if temp4 = 3 then var34 = %00000111
   ;if temp4 = 4 then var34 = %00001111
   ;if temp4 = 5 then var34 = %00011111
   ;if temp4 = 6 then var34 = %00111111
   ;var34 = %01111111

   drawscreen
   
   COLUPF = $96
   COLUP1 = $0C
   temp4 = rand&7
   COLUP0 = $42+temp4

   _Ch0_Duration = _Ch0_Duration - 1
   
   if _Ch0_Duration  then goto __Player_Dying ; casue a delay between sprite and sound updates
   
   _Ch0_Duration= 6 

   ; Dying sound
   if _Ch0_Counter <24 then _Ch0_Counter = _Ch0_Counter +1
   if _Ch0_Counter = 24 then AUDV0 = 0 : AUDV1 = 0 


   temp5 = rand&7
   temp6 = rand&7
   player0x = 107+temp5 : player0y = 43+temp6
 
   AUDC0 = 2
   AUDF0 = _Ch0_Counter
   AUDC1 = 7
   AUDF1 = _Ch0_Counter 

   ;  Deal with the rest game function
   if !switchreset then _Bit0_Reset_Restrainer{0} = 0 : goto __Player_Dying
   if _Bit0_Reset_Restrainer{0} then goto __Player_Dying
   goto __Start_Restart bank1



   ;***************************************
   ; Ttle Screen
   ;
__Title_Screen

   playfield:
   ...XXX.........X.X..............
   ...X...XX.X.X..XXX.X.X.XX..XXX..
   ...XX.X.X..X...X.X.X.X.X.X..X...
   ...X..XX..X.X..X.X.XX..X.X..X...
   ................................
   ................................
   ....XXX.XXXX.XXXX.XX..X.XXX.....
   ...X..X.X..X.X....XXX.X.X..X....
   ..XXXXX.XXX..XXX..X.XXX.XXXXX...
   .X....X.X.XX.X....X..XX.X....X..
   X.....X.X..X.XXXX.X...X.X.....X.
end
   
   data _Title_Music
   8,12,31
   15
   2,12,31
   5
   8,12,31
   8
   2,12,31
   2
   5,12,27
   15
   2,12,27
   5
   8,12,26
   23
   2,12,26
   7
   8,12,31
   15
   2,12,31
   5
   8,12,31
   8
   2,12,31
   2
   5,12,27
   15
   2,12,27
   5
   8,12,26
   23
   2,12,26
   7
   255
end

   _Ch0_Counter = 0
   _Ch0_Duration = 1
   _Ch1_Duration = 0 ; used to sequence the Tite sceen, not sound
   
__Animate_Title   
   
   drawscreen
   
   COLUPF = _Ch1_Duration 
   COLUBK = $00
   COLUP0 = $9C 

   player0x = _Ch1_Duration : player0y = 44

   if _Animation_Counter&%00111111 < 4 then _Animation_Counter = _Animation_Counter + 1 : goto __Skip_Animate_Step
   _Animation_Counter = _Animation_Counter & %11000000
   if _Animation_Counter < 128 then _Animation_Counter = _Animation_Counter + 64 else _Animation_Counter = _Animation_Counter & %00111111
   if _Animation_Counter{6} then goto __Fox_RunA_Title 
   if _Animation_Counter{7} then goto __Fox_RunB_Title else goto __Fox_Title

__Fox_RunA_Title
 player0:
 %10010000
 %10001000
 %01001000
 %00110000
 %00111100
 %00110000
 %00011000
 %00011000
end
 goto __Skip_Animate_Step

__Fox_RunB_Title
 player0:
 %00010000
 %10010000
 %11110000
 %00110000
 %00111100
 %00110000
 %00011000
 %00011000
end
 goto __Skip_Animate_Step

__Fox_Title 
 player0:
 %01001000
 %01001000
 %01101000
 %00110000
 %00111100
 %00110000
 %00011000
 %00011000
end

__Skip_Animate_Step
   
   if _Ch1_Duration = 160 then AUDV0 = 0 : goto __Return_From_Title bank1
   _Ch1_Duration = _Ch1_Duration + 1
  
   ;Play the music
   _Ch0_Duration = _Ch0_Duration - 1

   if _Ch0_Duration then goto __Keep_Playing_Note

   temp4 = _Title_Music[_Ch0_Counter] : _Ch0_Counter = _Ch0_Counter + 1
   if temp4 = 255 then AUDV0 = 0 : goto __Keep_Playing_Note ;  stop playing
   
   temp5 = _Title_Music[_Ch0_Counter] : _Ch0_Counter = _Ch0_Counter + 1
   temp6 = _Title_Music[_Ch0_Counter] : _Ch0_Counter = _Ch0_Counter + 1

   AUDV0 = temp4
   AUDC0 = temp5
   AUDF0 = temp6
 
   _Ch0_Duration = _Title_Music[_Ch0_Counter] : _Ch0_Counter = _Ch0_Counter + 1


__Keep_Playing_Note


   goto __Animate_Title


   ;********************************************
   ;   Enemay injured Effect
   ;
__Enemy_Injured
   
Injured
   player1:
   %01101100
   %00101000
   %10111010
   %10111010
   %01111100
   %00010000
   %00111000
   %00111000
end 
   _Ch1_Duration = 20
   AUDV0 = 8
   AUDC0 = 3
  
__Lift_Injured_Enemy
  COLUP0  = $9C 									; need to set player 0 color every redraw
  if _Player0_Reflected_Bit5{5} then REFP0 = $08 else REFP0 = $00 ; need to set reflected bit each redraw
  COLUP1 = player1y & $46  							; Enemy color will change with height
  COLUPF = $08 									; need to set background color with eac redraw
  AUDF0 = player1y & $1F							; Sound will increase as enemy is lifted

  drawscreen

  if _Ch1_Duration >1 then _Ch1_Duration = _Ch1_Duration - 1 : goto __Lift_Injured_Enemy
  _Ch1_Duration = 2
  if player1y > 2 then player1y = player1y - 1 : goto __Lift_Injured_Enemy
  player1:
   %00000000
   %00000000
   %00000000
   %00000000
   %00000000
   %00000000
   %00000000
   %00000000
end 
  _Ch1_Duration = 0 							; let enemy movemnt begin again
  _No_Enemy_Present_Bit3{3} = 1 					; a new enemey will not appear until an new screen is entered
  AUDV0 = 0									; silence the sound
  _Ch0_Sound = 0 : _Ch0_Duration = 0 : _Ch0_Counter = 0     ; clear the "hit" sound upon return
  score = score + 10000 ; Get poiints for each kill
  goto __Return_From_Enemy_Injured bank1

   ;,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
   ;```````````````````````````````````````````````````````````````
   ;
   ;  End of second section of main loop.
   ;
   ;,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
   ;```````````````````````````````````````````````````````````````

   ;***************************************************************
   ;***************************************************************
   ;
   ;  Sound data for walking.
   ;
   data _SD_Walk
   2,14,8
   1
   2,0,1
   4
   2,14,8
   1
   255
end




   ;***************************************************************
   ;***************************************************************
   ;
   ;  Sound data for shot hitting wall.
   ;
   data _SD_Shot_Wall
   8,8,0
   1
   8,8,1
   1
   8,14,1
   1
   8,8,0
   1
   8,8,2
   1
   8,14,2
   1
   8,8,1
   1
   7,8,3
   1
   6,8,2
   1
   5,8,4
   1
   4,8,3
   1
   3,8,5
   1
   2,14,4
   4
   255
end





   ;***************************************************************
   ;***************************************************************
   ;
   ;  Sound data for shooting missile.
   ;
   data _SD_Shoot_Miss
   8,15,0
   1
   12,15,1
   1
   8,7,20
   1
   10,15,3
   1
   8,7,22
   1
   10,15,5
   1
   8,15,6
   1
   10,7,24
   1
   8,15,8
   1
   9,7,27
   1
   8,15,10
   1
   7,14,11
   1
   6,15,12
   1
   5,6,13
   1
   4,15,14
   1
   3,6,27
   1
   2,6,30
   8
   255
end





   ;***************************************************************
   ;***************************************************************
   ;
   ;  Sound data for touching an object.
   ;
   data _SD_Touch_Object
   12,4,23
   4
   10,4,29
   4
   8,4,23
   4
   6,4,29
   4
   4,4,23
   4
   3,4,29
   4
   2,4,23
   1
   1,4,29
   1
   255
end





   ;***************************************************************
   ;***************************************************************
   ;
   ;  Sound data for touching enemy.
   ;
   data _SD_Touch_Enemy
   2,7,11
   2
   10,7,12
   2
   8,7,13
   2
   8,7,14
   2
   8,7,21
   8
   4,7,22
   2
   2,7,23
   10
   255
end






   ;,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
   ;```````````````````````````````````````````````````````````````
   bank 3
   ;,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
 
  ;  Enemy has run out of the arena while being chase by a missile
__Enemy_Escaped 
  _Carl_Present_Bit6{6} = 0
  _Bob_Present_Bit5{5} = 0
  _Nova_Present_Bit4{4} = 0 
  _No_Enemy_Present_Bit3{3} = 1
  player1x= 0 : player1y = 0
  goto __Skip_Enemy_Movement bank1



   ;***************************************************************
   ;***************************************************************
   ;  playfield Selection
   ;***************************************************************
   ;  Rounds 1& 2 is 3X3, Rounds 3 & 4 is 3X3  Rounds 5&6 = 5x5
   ;  Round 1 key+1 station. 2 = Health, 3= Bow 4 = CodeA, 5 = XG7 6 = Code B
   ;```````````````````````````````````````````````````````````````
   ; Jumps to drawings of the new playfield
   ; These calls are from Bank 1 and the Joystick edge checks

   ;********************************
   ;**** 5x5 World Playfields ******
__Next_Playfield
__Next_5x5_Playfield   
     
   ;  the Shield will only last 8 rooms.  Couont and check and reset
   if _Has_Shield_Bit4{4} then _Shield_Position_Counter = _Shield_Position_Counter +16 ; Upper bits count the number of rooms the shield will be active	
   if _Shield_Position_Counter > 128 then _Shield_Position_Counter = 0 : _Has_Shield_Bit4{4} = 0 ; gone though 8 rooms with shield, now its used up

   ;  Find the next room to display
   if _Present_Playfield = $00 then goto __Field_0_0 
   if _Present_Playfield = $01 then goto __Field_0_1 
   if _Present_Playfield = $02 then goto __Field_0_2 
   if _Present_Playfield = $03 then goto __Field_0_3 
   if _Present_Playfield = $04 then goto __Field_0_4 

   if _Present_Playfield = $10 then goto __Field_1_0 
   if _Present_Playfield = $11 then goto __Field_1_1 
   if _Present_Playfield = $12 then goto __Field_1_2 
   if _Present_Playfield = $13 then goto __Field_1_3 
   if _Present_Playfield = $14 then goto __Field_1_4 

   if _Present_Playfield = $20 then goto __Field_2_0  
   if _Present_Playfield = $21 then goto __Field_2_1 
   if _Present_Playfield = $22 then goto __Field_2_2 
   if _Present_Playfield = $23 then goto __Field_2_3 
   if _Present_Playfield = $24 then goto __Field_2_4 

   if _Present_Playfield = $30 then goto __Field_3_0 
   if _Present_Playfield = $31 then goto __Field_3_1 
   if _Present_Playfield = $32 then goto __Field_3_2 
   if _Present_Playfield = $33 then goto __Field_3_3 
   if _Present_Playfield = $34 then goto __Field_3_4 
 
   if _Present_Playfield = $40 then goto __Field_4_0 
   if _Present_Playfield = $41 then goto __Field_4_1 
   if _Present_Playfield = $42 then goto __Field_4_2 
   if _Present_Playfield = $43 then goto __Field_4_3 
   if _Present_Playfield = $44 then goto __Field_4_4 
   
   ; if you got here, then you went off the arena and died!!
   ;goto __Player_Death bank2


  ;```````````````````````````````````````````````````````````````
  ;  playfield Features
  ;    bits 0-3 Location of the Station
  ;    bits 4-5 Enemy character 0 = none, 1 = Nova, 2 = Bob, 3 = Carl
  ;    Bits 6-7 Likelyhood of Enemy 0 = 12% 2 = 25% 3 = 50% 4 = 100%
  ;    Station Location 0 = none. 

__Field_0_0
 playfield:
 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
 XX......XX.....................X
 X...............................
 X...............................
 XX......XX......................
 XXXXXXXXXX......................
 X...............................
 X...............................
 X...............................
 X...............................
 XX.............................X
end
 _Playfield_Features  = %00000000
 goto __Play_Field_Selected bank1



__Field_0_1
 playfield:
 XX.............................X
 X...............................
 X...............................
 X.........XXX....X.....X...X....
 X........X......XX.X....X.X.....
 X........X.X....X..X............
 X........X......X.XX....X.X.....
 X........X........X....X...X....
 X...............................
 X...............................
 XX.............................X
end
 _Playfield_Features  = %01110000
 goto __Play_Field_Selected bank1


__Field_0_2
 playfield:
 XX.............................X
 XX..............................
 XXXXXXXXXXXXX........X..........
 X............X......X...........
 X.............X....X............
 X.........XX..X....X............
 X........X..X.X....X............
 X.............X....X............
 X.............X....X............
 X............X......X...........
 XX..........X........X.........X
end
 _Playfield_Features  = %11111001 ; Station 0
 goto __Play_Field_Selected bank1


__Field_0_3
 playfield:
 XX..........X........X.........X
 X...........X...................
 XXXXXX...XXXX...................
 X...........X...................
 X...........X.........XXX.......
 X....XXXXXXXX........X.X.X......
 X...........X.......XXXXXXX.....
 X...........X.......XXX.XXX.....
 XXXXXX......X...................
 X...........X...................
 XX..........X..................X
end
 _Playfield_Features  = %10110000
 goto __Play_Field_Selected bank1


__Field_0_4
 playfield:
 XX..........X..................X
 X...........XX..................
 X..........XX...................
 X.X........XXX..................
 X.X.........XX..................
 XXX.........XXXXXXX.............
 X.X.X...........................
 XXXXXX..........................
 XXX.XXXX........................
 X.XXX..XXX.....................X
 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
end
 _Playfield_Features  = %11110000
 goto __Play_Field_Selected bank1


__Field_1_0
 playfield:
 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
 X..............................X
 ................................
 ..........XXX.XX.XXX............
 ........XXXXXXXXXXXXXX..........
 .........XXX......XXX...........
 ..........X........X............
 ..........X........X............
 .........XXX......XXX...........
 ................................
 X..............................X
end
 _Playfield_Features  = %01010000
 goto __Play_Field_Selected bank1

__Field_1_1
 playfield:
 X..............................X
 ................................
 ................................
 ....X..X...X...X...XXX.....XXX..
 ....X..X...X...X...X............
 ....XX.X....X..X...X..X.....X...
 ....X..X....X......X..X.....X...
 ....X..X.....XX....X..X.....X...
 ................................
 ................................
 X..............................X
end
 _Playfield_Features  = %01110000
 goto __Play_Field_Selected bank1


__Field_1_2 
 playfield:
 X..............................X
 ................................
 ...........XXXXXXXX.............
 ..........XX......XX............
 .........X..X....X..X...........
 .........X..........X...........
 ................................
 ................................
 XXXXXXXXXXXXX.....XXXXXXXXXXXXXX
 ............X.....X.............
 X...........X.....X............X
end
 _Playfield_Features  = %11110110
 goto __Play_Field_Selected bank1


__Field_1_3
 playfield:
 X...........X.....X............X
 ............X.....X.............
 ...........XX.....XX............
 ..........X.........X...........
 .........X...........X..........
 ................................
 ................................
 ..............XXX...............
 ............XXXXXXX.............
 ..............XXX...............
 X..............................X
end
 _Playfield_Features  = %10110000
 goto __Play_Field_Selected bank1


__Field_1_4
 playfield:
 X..............................X
 .......................X.X......
 ..............X.X.......X.......
 ...............X....X.X.X.......
 ...............X.....X..........
 .....................X.X.X......
 ........................X.......
 ..XX....................X.......
 .X..X...........................
 X..............................X
 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
end
 _Playfield_Features  = %11111100
 goto __Play_Field_Selected bank1


__Field_2_0
 playfield:
 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
 X..............................X
 ................................
 .........X..X..X..X.............
 .........XXXXXXXXXX.............
 .......XXX........X..X..X.......
 .......X.X........XXXXXXX.......
 .......XXX........X.....X.......
 ................................
 ................................
 X..............................X
end
  _Playfield_Features  = %10010000
  goto __Play_Field_Selected bank1


__Field_2_1
 playfield:
 X..............................X
 ..........................XX....
 .........................X..X...
 ................................
 ..............XXX...............
 ............XX..................
 ............X...................
 ...........X....................
 ..........XX....................
 ...........XX...................
 X...........X..................X
end
  _Playfield_Features  = %11010011
  goto __Play_Field_Selected bank1


__Field_2_2
 playfield:
 X...........X..................X
 ...........X....................
 ..........XX....................
 .........XX........XXX..........
 ........XX........X.X.X.........
 ........XX........XXXXX.........
 .........XX........XXX..........
 ..........XXX....XXXX...........
 ............XXXXXXX.............
 ................................
 X..............................X
end
  _Playfield_Features  = %01100000
  goto __Play_Field_Selected bank1
  

__Field_2_3
 playfield:
 X..............................X
 ................................
 ................................
 ..XX............................
 .X..X..........XXXXX............
 ....................X...........
 .....................X.X........
 ......................X.XX......
  ......................X.X......
 .......................XX.......
 X......................X.......X
end
 _Playfield_Features  = %11100100
 goto __Play_Field_Selected bank1


__Field_2_4
 playfield:
 X......................X.......X
 ......................XX........
 ..........X.X.......XX.XX.......
 ........X.XXX........X.X........
 .......XXXX.X...................
 .......XXXXXX...................
 ................................
 .......................XX.......
 ......................XXXX.....
 X.....................X..X.....X
 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
end
  _Playfield_Features  = %10100000
  goto __Play_Field_Selected bank1


__Field_3_0
 playfield:
 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
 X..............................X
 .........X......................
 ......X.X.X.X...................
 .......XXXXX....................
 .......X...X....................
 ................................
 ..................XXXXXXXXXXXXXX
 .................XX.............
 .................XX.............
 X...............XX.............X
end
  _Playfield_Features  = %10010000
  goto __Play_Field_Selected bank1


__Field_3_1
 playfield:
 X..............X...............X
 ............XXX.................
 ...........X....................
 ...........X......XX............
 ...........X.....X..X...........
 ............XX..................
 ..............X..........XXXXXXX
 ...............XXXXXXXXXXX......
 ................................
 ................................
 X..............................X
end
  _Playfield_Features  = %11010110
  goto __Play_Field_Selected bank1


__Field_3_2
 playfield:
 X..............................X
 ................................
 ................................
 ......X.................X.......
 .............X..X...............
 ............X....X..............
 ............X....X..............
 .............X..X...............
 ......X.................X.......
 ................................
 X..............................X
end
  _Playfield_Features  = %10010000
  goto __Play_Field_Selected bank1


__Field_3_3
 playfield:
 X..............................X
 ................................
 ................................
 ................................
 ..............X.X...............
 ............XXXXXX..............
 ...........X.........X..........
 ...........X.....X...XX.........
 ...........XXX...XXX.XX.........
 ................................
 X..............................X
end
  _Playfield_Features  = %10100000
  goto __Play_Field_Selected bank1


__Field_3_4
 playfield:
 X..............................X
 ................................
 ................................
 ......X.X.X.X......X.X.X.X......
 ......XX.XXXX..XX..XXXX.XX......
 .......XXXXXXXXXXXXXXXXXX.......
 .......XX.XXXX....XXXX.XX.......
 ................................
 ................................
 X..............................X
 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
end
  _Playfield_Features  = %10100000
  goto __Play_Field_Selected bank1

__Field_4_0
 playfield:
 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
 X..............................X
 ...............................X
 ..........................XX...X
 .....XXXX................X..X..X
 .....XX.XX.....................X
 ....XX.X.XX....................X
 XXXXXXXXXXXX...................X
 ...............................X
 ...............................X
 X.............................XX
end
 _Playfield_Features  = %11010111
 goto __Play_Field_Selected bank1


__Field_4_1
 playfield:
 X.............................XX
 ...............................X
 ...................X...........X
 ...................XXXXXXXXXXXXX
 ....X...................X......X
 ....X..........................X
 XXXXXXXXXXXXXX.................X
 ........................X......X
 ........................XXXXXXXX
 ...............................X
 X.............................XX
end
  _Playfield_Features  = %11010000
  goto __Play_Field_Selected bank1


__Field_4_2
 playfield:
 X.............................XX
 ...............................X
 .........................X.....X
 ....X....X...............X.....X
 ...XX....XX.............X......X
 XXXXXXXXXXX............XXX....XX
 .....................XXX.......X
 ...................XXX.........X
 ......XXXXXXXXXXXXXX...........X
 ...............................X
 X.............................XX
end
  _Playfield_Features  = %10010000
  goto __Play_Field_Selected bank1


__Field_4_3
 playfield:
 X.............................XX
 ...............................X
 .............................XXX
 .......XXXXXXX..............X..X
 .............XXXXXXXX.....XX...X
 .........................X.....X
 ........XX.....................X
 .......XX.X......X.............X
 ......XXXXXX......X.....XX.....X
 .....XX.XX.X......XX..XXX......X
 X....XXXXXXX......XXXXXXXX....XX
end
 _Playfield_Features  = %10100000
 goto __Play_Field_Selected bank1


__Field_4_4
 playfield:
 X....XXXXXXX.......XXXXXXX....XX
 .....XX.X..........X.X.X.......X
 .....X..............XXX........X
 X.X.X...............XXX........X
 .....................XX........X
 ..........XX........XX.........X
 .........X..X.......X..........X
 ...................X...........X
 ...............................X
 X..............................X
 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
end
 _Playfield_Features  = %11101001 ; station 7
 goto __Play_Field_Selected bank1

   ;************************************
   ;  Player Animation
   ;
__Player_Animation
   ; if the Shield is active, rotate the missile around the player
  if !_Has_Shield_Bit4{4} || _Bit7_M0_Moving{7} then goto __Skip_Shielding
  _Shield_Position_Counter = _Shield_Position_Counter + 1
  temp4 = _Shield_Position_Counter & %00001111 ; Lower 4 bits step though the shild positions, Upper 4 bits are used to count how long the shield will stay on
  if temp4 > 7 then temp4 = 0 : _Shield_Position_Counter = _Shield_Position_Counter & %11110000
  if temp4 = 0 then missile0y  = player0y-8 : missile0x = player0x +4
  if temp4 = 1 then missile0y  = player0y-7 : missile0x = player0x +7
  if temp4 = 2 then missile0y  = player0y-4 : missile0x = player0x +8
  if temp4 = 3 then missile0y  = player0y-1 : missile0x = player0x +7
  if temp4 = 4 then missile0y  = player0y+0 : missile0x = player0x +4
  if temp4 = 5 then missile0y  = player0y-1 : missile0x = player0x +1
  if temp4 = 6 then missile0y  = player0y-4 : missile0x = player0x 
  if temp4 = 7 then missile0y  = player0y-7 : missile0x = player0x +1
__Skip_Shielding

  ; Time the running motions
  if _Animation_Counter&%00111111 < 4 then _Animation_Counter = _Animation_Counter + 1 : goto __Return_From_Animation bank1
  _Animation_Counter = _Animation_Counter & %11000000
  if _Animation_Counter < 128 then _Animation_Counter = _Animation_Counter + 64 else _Animation_Counter = _Animation_Counter & %00111111
  
  ; if the electric shock prototion shield is active
  if _Has_Shockproof_bit5{5} then temp4 = rand&7 : COLUP0 = $16 + temp4 : goto __Fox_Electric_Shield

 
  ; Fox has the XG7
  if _Animation_Counter{6} && _Has_XG7_Bit3{3} then goto __Fox_RunA_XG7 
  if _Animation_Counter{7} && _Has_XG7_Bit3{3} then goto __Fox_RunB_XG7
  if !_Animation_Counter{7} && _Has_XG7_Bit3{3} then goto __Fox_XG7
  
  ; Fox has the Bow
  if _Animation_Counter{6} && _Has_Bow_Bit2{2} then goto __Fox_RunA_Bow 
  if _Animation_Counter{7} && _Has_Bow_Bit2{2} then goto __Fox_RunB_Bow 
  if !_Animation_Counter{7} && _Has_Bow_Bit2{2} then goto __Fox_Bow   
  
  ; Normal Fox
  if _Animation_Counter{6} then goto __Fox_RunA 
  if _Animation_Counter{7} then goto __Fox_RunB else goto __Fox 

__Fox_Electric_Shield 
  player0:
 %00101010
 %01101011
 %01100111
 %01100001
 %01100111
 %01110011
 %01110011
 %00111110
end
   goto __Return_From_Animation bank1
  
__Fox
 player0:
 %01001000
 %01001000
 %01101000
 %00110000
 %00111100
 %00110000
 %00011000
 %00011000
end
 goto __Return_From_Animation bank1

__Fox_RunA
 player0:
 %10010000
 %10001000
 %01001000
 %00110000
 %00111100
 %00110000
 %00011000
 %00011000
end 
  goto __Return_From_Animation bank1


__Fox_RunB
 player0:
 %00010000
 %10010000
 %11110000
 %00110000
 %00111100
 %00110000
 %00011000
 %00011000
end
  goto __Return_From_Animation bank1

__Fox_Bow
 player0:
 %01001000
 %01001000
 %01101010
 %00110001
 %00111101
 %00110001
 %00011010
 %00011000
end 
 ;goto __New_Fox_Sprite bank1
 goto __Return_From_Animation bank1

__Fox_RunA_Bow
 player0:
 %10010000
 %10001000
 %01001010
 %00110001
 %00111101
 %00110001
 %00011010
 %00011000
end
  goto __Return_From_Animation bank1

__Fox_RunB_Bow
 player0:
 %00010000
 %10010000
 %11110010
 %00110001
 %00111101
 %00110001
 %00011010
 %00011000
end 
  goto __Return_From_Animation bank1

__Fox_XG7
 player0:
 %10010000
 %10010000
 %11010000
 %01100100
 %01111100
 %01101111
 %00110010
 %00110000
end
  goto __Return_From_Animation bank1

__Fox_RunA_XG7
 player0:
 %10010000
 %10001000
 %01001000
 %01110100
 %01111100
 %01101111
 %00110010
 %00110000
end
  goto __Return_From_Animation bank1

__Fox_RunB_XG7
 player0:
 %00010000
 %10010000
 %11110000
 %01110100
 %01111100
 %01101111
 %00110010
 %00110000
end
  goto __Return_From_Animation bank1

__Fox_Bow_Touched
 player0:
 %01001000
 %01001000
 %01101010
 %00110001
 %00111101
 %00110001
 %00011010
 %00011000
end 
 goto __New_Fox_Sprite bank1


__Fox_XG7_Touched
 player0:
 %10010000
 %10010000
 %11010000
 %01100100
 %01111100
 %00110111
 %00011010
 %00011000
end
 goto __New_Fox_Sprite bank1




  ;************************************
  ;  Enemy Animation
  ;
__Enemy_Animation
  if _No_Enemy_Present_Bit3{3} then goto __Blank_Enemy   ;  There are no enemys on the screen...just return
  if _Nova_Present_Bit4{4} then  COLUP1 = $44 : goto __Nova
  if _Bob_Present_Bit5{5}  then  COLUP1 = $64 : goto __Bob
  if _Carl_Present_Bit6{6} then  COLUP1 = $F4 : goto __Carl
 

__Nova
 if _Bit0_Nova_Dead{0} then goto __Blank_Enemy
 player1:  ; standing
 %11011000
 %10010000
 %11110000
 %01100000
 %01111000
 %00100100
 %01110010
 %01111001
end
 if player1x&2 then goto __Return_From_Enemy_Animation bank1  

__Nova_Walk
 player1:
 %01110000
 %01100000
 %01100000
 %01100000
 %01111000
 %00100100
 %01110010
 %01111001
end
 goto __Return_From_Enemy_Animation bank1  


__Carl
 if _Bit2_Carl_Dead{2} then goto __Blank_Enemy
 player1:
 %10011000
 %11010000
 %01110000
 %11100100
 %11111100
 %11100100
 %01110100
 %01110100
end
 if player1x&2 then goto __Return_From_Enemy_Animation bank1  

__Carl_Walk
 player1:
 %01110000
 %01100000
 %01100000
 %11100100
 %11111100
 %11100100
 %01110100
 %01110100
end
 goto __Return_From_Enemy_Animation bank1  

__Bob
 if _Bit1_Bob_Dead{1} then goto __Blank_Enemy
 player1:
 %10011000
 %11010000
 %01110000
 %01110100
 %01111111
 %00100100
 %00110000
 %01110000
end
 if player1x&2 then goto __Return_From_Enemy_Animation bank1  

__Bob_Walk
 player1:
 %01010000
 %01010000
 %01110000
 %01110100
 %01111111
 %00100100
 %00110000
 %01110000
end 
 goto __Return_From_Enemy_Animation bank1  


__Blank
 player1:
 %00000000
 %00000000
 %00000000
 %00000000
 %00000000
 %00000000
 %00000000
 %00000000
end
 goto __Enemy_Selected bank1


__Cash
 player1:
 %00000000
 %00010000
 %01111100
 %00010100
 %01111100
 %01010000
 %01111100
 %00010000
end
 _Cash_In_Room_Bit4{4} = 1
 goto __Enemy_Selected bank1


__Blank_Key
 player1:
 %00000000
 %00000000
 %00000000
 %00000000
 %00000000
 %00000000
 %00000000
 %00000000
end
 goto __Touched_Enemy bank1

__Blank_Enemy
 player1:
 %00000000
 %00000000
 %00000000
 %00000000
 %00000000
 %00000000
 %00000000
 %00000000
end
 goto __Return_From_Enemy_Animation bank1

__Key
 player1:
 %00000000
 %00000000
 %00000000
 %11101010
 %10111110
 %11100000
 %00000000 %00000000
end
 goto __Enemy_Selected bank1

__Bow
 player1:
 %00010000
 %00001000
 %10100100
 %11111110
 %10011111
 %00000100
 %00001000
 %00010000
end

_Airplane
 player1:
 %00100000
 %00110000
 %10011000
 %01111111
 %11111110
 %10010000
 %00100000
 %00000000
end

__XG7
 player1:
 %00000000
 %00000000
 %11000000
 %11101000
 %11111110
 %00100000
 %01110000
 %00000000
end

__Station
 player1:
 %11111100
 %11111100
 %11011100
 %11011100
 %11011100
 %01111000
 %01111000
 %00110000
end

__Code_A
 player1:
 %00111110
 %01101100
 %01010100
 %01101110
 %01111110
 %01100100
 %01100100
 %00111110
end

__Code_B
 player1:
 %00111100
 %01111110
 %01110110
 %00101010
 %00111110
 %01100110
 %01100110
 %00111100
end


   ;,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
   ;```````````````````````````````````````````````````````````````
   bank 4
   ;,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
   ;```````````````````````````````````````````````````````````````


   ;********************************
   ;**** 4x4 World Playfields ******

__Next_4x4_Playfield   
     
   ;  the Shield will only last 8 rooms.  Couont and check and reset
   if _Has_Shield_Bit4{4} then _Shield_Position_Counter = _Shield_Position_Counter +16 ; Upper bits count the number of rooms the shield will be active	
   if _Shield_Position_Counter > 128 then _Shield_Position_Counter = 0 : _Has_Shield_Bit4{4} = 0 ; gone though 8 rooms with shield, now its used up

   ;  Find the next room to display
   if _Present_Playfield = $00 then goto __4x4_Field_0_0
   if _Present_Playfield = $01 then goto __4x4_Field_0_1 
   if _Present_Playfield = $02 then goto __4x4_Field_0_2 
   if _Present_Playfield = $03 then goto __4x4_Field_0_3 
 

   if _Present_Playfield = $10 then goto __4x4_Field_1_0 
   if _Present_Playfield = $11 then goto __4x4_Field_1_1 
   if _Present_Playfield = $12 then goto __4x4_Field_1_2 
   if _Present_Playfield = $13 then goto __4x4_Field_1_3 
  
   if _Present_Playfield = $20 then goto __4x4_Field_2_0  
   if _Present_Playfield = $21 then goto __4x4_Field_2_1 
   if _Present_Playfield = $22 then goto __4x4_Field_2_2 
   if _Present_Playfield = $23 then goto __4x4_Field_2_3 
 
   if _Present_Playfield = $30 then goto __4x4_Field_3_0 
   if _Present_Playfield = $31 then goto __4x4_Field_3_1 
   if _Present_Playfield = $32 then goto __4x4_Field_3_2 
   if _Present_Playfield = $33 then goto __4x4_Field_3_3 
   
   ; if you got here, then you went off the arena and died!!
   ;goto __Player_Death bank2



  ;```````````````````````````````````````````````````````````````
  ;  playfield Features
  ;    bits 0-3 Location of the Station
  ;    bits 4-5 Enemy character 0 = none, 1 = Nova, 2 = Bob, 3 = Carl
  ;    Bits 6-7 Likelyhood of Enemy 0 = 12% 2 = 25% 3 = 50% 4 = 100%
  ;    Station Location 0 = none. 

__4x4_Field_0_0
 playfield:
 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
 XX......XX.....................X
 X...............................
 X...............................
 XX......XX......................
 XXXXXXXXXX......................
 X...............................
 X...............................
 X...............................
 X...............................
 XX.............................X
end
 _Playfield_Features  = %00000000
 goto __Play_Field_Selected bank1



__4x4_Field_0_1
 playfield:
 XX.............................X
 X...............................
 X...............................
 X.........XXX....X.....X...X....
 X........X......XX.X....X.X.....
 X........X.X....X..X............
 X........X......X.XX....X.X.....
 X........X........X....X...X....
 X...............................
 X...............................
 XX.............................X
end
 _Playfield_Features  = %01110000
 goto __Play_Field_Selected bank1


__4x4_Field_0_2
 playfield:
 XX.............................X
 XX..............................
 XXXXXXXXXXXXX.......X...........
 X............X.......X..........
 X.............X.......X.........
 X.........XX..X.......X.........
 X........X..X.X.......X.........
 X.............X.......X.........
 X.............X.......X.........
 X............X.......X..........
 XX..........X.......X..........X
end
 _Playfield_Features  = %11111001 ; Station 0
 goto __Play_Field_Selected bank1


__4x4_Field_0_3
 playfield:
 XX..........X......X...........X
 X...........X......X............
 XXXXXX...XXXX...................
 X...........X...................
 X...........X.........XXX.......
 X....XXXXXXXX........X.X.X......
 X...................XXXXXXX.....
 X...................XXX.XXX.....
 X...............................
 X..............................X
 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
end
 _Playfield_Features  = %10110000
 goto __Play_Field_Selected bank1



__4x4_Field_1_0
 playfield:
 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
 X..............................X
 ................................
 ..........XXX.XX.XXX............
 ........XXXXXXXXXXXXXX..........
 .........XXX......XXX...........
 ..........X........X............
 ..........X........X............
 .........XXX......XXX...........
 ................................
 X..............................X
end
 _Playfield_Features  = %01010000
 goto __Play_Field_Selected bank1

__4x4_Field_1_1
 playfield:
 X..............................X
 ................................
 ................................
 ....X..X...X...X...XXX.....XXX..
 ....X..X...X...X...X............
 ....XX.X....X..X...X..X.....X...
 ....X..X....X......X..X.....X...
 ....X..X.....XX....X..X.....X...
 ................................
 ................................
 X..............................X
end
 _Playfield_Features  = %01110000
 goto __Play_Field_Selected bank1


__4x4_Field_1_2 
 playfield:
 X..............................X
 ................................
 ...........XXXXXXXX.............
 ....X.....XX......XX.....X......
 ....X....X..X....X..X....X......
 ....X....X..........X....X......
 ....X....................X......
 ....XX..................XX......
 .....XXXXXXXX.....XXXXXXX.......
 ............X.....X.............
 X...........X.....X............X
end
 _Playfield_Features  = %11110110
 goto __Play_Field_Selected bank1


__4x4_Field_1_3
 playfield:
 X...........X.....X............X
 ............X.....X.............
 ...........XX.....XX............
 ..........X.X.....X.X...........
 .........X..X.....X..X..........
 .........XXXX.....XXXX.........X
 .........X...........X.........X
 ...............................X
 ...............................X
 X..........XX.XXX.XX...........X
 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
end
 _Playfield_Features  = %10110000
 goto __Play_Field_Selected bank1


__4x4_Field_2_0
 playfield:
 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
 X..............................X
 ................................
 .........X..X..X..X.............
 .........XXXXXXXXXX.............
 .......XXX........X..X..X.......
 .......X.X........XXXXXXX.......
 .......XXX........X.....X.......
 ................................
 ................................
 X.................XXXXXXXXXXXXXX
end
  _Playfield_Features  = %10010000
  goto __Play_Field_Selected bank1


__4x4_Field_2_1
 playfield:
 X.................XXXXXXXXXXXXXX
 ..................XX......XX....
 ........XX...XXXXXX......X..X...
 ..................X.........X...
 ..............XXXXX.........X...
 ........XX..XX..............X...
 ......................XXXXXXX...
 ................................
 ........XX..XX..................
 ..............XXXXXXXX..........
 X..............................X
end
  _Playfield_Features  = %11010011
  goto __Play_Field_Selected bank1


__4x4_Field_2_2
 playfield:
 X..............................X
 .......X.X.X.X.X.X.X.X.X........
 ......X.................X.......
 .....X....X...X..........X......
 ....X.....XX..X....XX.....X.....
 ....X....XXX.XX...XXX.....X.....
 .........X.XXXX..XXXXX..........
 ........XXXXXXXXXXX.XXX.........
 ........XXXX...XXXXXXXX.........
 ................................
 X..............................X
endend
  _Playfield_Features  = %01100000
  goto __Play_Field_Selected bank1
  

__4x4_Field_2_3
 playfield:
 X..............................X
 ................................
 ................................
 ..XX...................XX.......
 .X..X.................X..X......
 X....XXXXXXXX....XXXXX..........
 X...........X........X..........
 X...........X........X..........
 X....................X..........
 X....................X.........X
 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
end
 _Playfield_Features  = %11100100
 goto __Play_Field_Selected bank1



__4x4_Field_3_0
 playfield:
 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
 X..............................X
 .........X.....................X
 ......X.X.X.X..................X
 .......XXXXX........X..........X
 .......X...X........X..........X
 ....................X..........X
 ..................XXX....XXXXXXX
 ..................X............X
 ..................X............X
 X.........XXXXXXXXX...........XX
end
  _Playfield_Features  = %10010000
  goto __Play_Field_Selected bank1


__4x4_Field_3_1
 playfield:
 X.........XXXXXXXXX...........XX
 ............XX.................X
 ............X..................X
 ............X.....XX.....X.....X
 ............X....X..X....X.....X
 ............X............X.....X
 ............XX...........X.....X
 ............XXXXXXXXXXXXXX.....X
 ...............XX..............X
 ...............X...............X
 X..............X........XXXXXXXX
end
  _Playfield_Features  = %11010110
  goto __Play_Field_Selected bank1


__4x4_Field_3_2
 playfield:
 X..............X........XXXXXXXX
 ...............X...............X
 ...............X...............X
 XXXXXXXXXXXXXXXX....XXXXXXXXXXXX
 ...............X...............X
 ...............X...............X
 ...............X.......X.......X
 ...X...........XXXXXXXXX.......X
 ...X...........................X
 ...X...........................X
 XXXX.....XXXXXXXXXXXXXXXXXXXXXXX
end
  _Playfield_Features  = %10010000
  goto __Play_Field_Selected bank1


__4x4_Field_3_3
  playfield:
 XXXX.....XXXXXXXXXXXXXXXXXXXXXXX
 ...X.....X.....................X
 ...X.....X.........XXXXXXXXX...X
 ...X.....XXX......XXXXXXXXXXX..X
 ...X..............XX..XXX..XX..X
 ...XXX.............XXXX.XXXX...X
 ...XXXXXXXXX........XXXXXXX....X
 ....................X.X.X.X....X
 ...............................X
 X...................X.X.X.X....X
 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
end
  _Playfield_Features  = %10100000
  goto __Play_Field_Selected bank1






   ;,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
   ; Playfield for the 3x3 world
__Next_3x3_Playfield
   
   ;  the Shield will only last 8 rooms.  Couont and check and reset
   if _Has_Shield_Bit4{4} then _Shield_Position_Counter = _Shield_Position_Counter +16 ; Upper bits count the number of rooms the shield will be active	
   if _Shield_Position_Counter > 128 then _Shield_Position_Counter = 0 : _Has_Shield_Bit4{4} = 0 ; gone though 8 rooms with shield, now its used up

   ; Display the enext playfield
   if _Present_Playfield = $00 then goto __3x3_Field_0_0 
   if _Present_Playfield = $01 then goto __3x3_Field_0_1 
   if _Present_Playfield = $02 then goto __3x3_Field_0_2 
    

   if _Present_Playfield = $10 then goto __3x3_Field_1_0 
   if _Present_Playfield = $11 then goto __3x3_Field_1_1 
   if _Present_Playfield = $12 then goto __3x3_Field_1_2 
 

   if _Present_Playfield = $20 then goto __3x3_Field_2_0  
   if _Present_Playfield = $21 then goto __3x3_Field_2_1 
   if _Present_Playfield = $22 then goto __3x3_Field_2_2 
  
   ; if you got here, then you went off the arena and died!!
   ;goto __Player_Death bank2


  ;```````````````````````````````````````````````````````````````
  ;  playfield Features
  ;    bits 0-3 Location of the Station
  ;    bits 4-5 Enemy character 0 = none, 1 = Nova, 2 = Bob, 3 = Carl
  ;    Bits 6-7 Likelyhood of Enemy 0 = 12% 1 = 25% 2 = 50% 3 = 100%
  ;    Station Location 0 = none. 

__3x3_Field_0_0
 playfield:
 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
 XX......XX.....................X
 X...............................
 X...............................
 XX......XX......................
 XXXXXXXXXX......................
 X...............................
 X...............................
 X...............................
 X...............................
 XX.............................X
end
 _Playfield_Features  = %00000000
 goto __Play_Field_Selected bank1

__3x3_Field_0_1
 playfield:
 XX.............................X
 X...............................
 X.......X......X...X...X........
 X.......X......X...X...X........
 X.......X......X...X...X........
 X.......X.......................
 X.......X.......................
 X.......XXXXXXXXXXXXXXXXXXXXXXXX
 X...............................
 X...............................
 XX.............................X
end
 _Playfield_Features  = %01110000
 goto __Play_Field_Selected bank1

__3x3_Field_0_2
 playfield:
 XX.............................X
 X...............................
 XXXXXXXXXX....XXXXXXX...........
 XX.................XX...........
 X...................X...........
 X.........XX........X...........
 X........X..X.......X...........
 X...............................
 X...............................
 XX.................XX..........X
 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
end
 _Playfield_Features  = %11111001 ; Station 0
 goto __Play_Field_Selected bank1


__3x3_Field_1_0
 playfield:
 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
 X..............................X
 ................................
 ...........XXXXXXXXX............
 .........XXXXXXXXXXXXX..........
 ........XXXXXXXXXXXXXXX.........
 .........XX....XXX..XX..........
 .........XX....XXXXXXX..........
 ................................
 ................................
 X..............................X
end
 _Playfield_Features  = %01010000
 goto __Play_Field_Selected bank1

__3x3_Field_1_1
 playfield:
 X..............................X
 ................................
 ................................
 ........XXXXXXXXXXXXXXXXXX......
 .........................X......
 .........................X......
 .........................X......
 XXXXXXXXXXXXX............X......
 .........................X......
 .........................X......
 X........................X.....X
end
 _Playfield_Features  = %01100000
 goto __Play_Field_Selected bank1

__3x3_Field_1_2
 playfield:
 X........................X.....X
 .........................X......
 .........XXXXXXXXXXXXXXXXX......
 .........XX.......XX....XX......
 .........X.......X..X....X......
 .........X...............X......
 .........XX.............XX......
 .........XXXXX...XXXXXXXXX......
 .........X......................
 X........X.....................X
 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
end
 _Playfield_Features  = %11110110
 goto __Play_Field_Selected bank1


__3x3_Field_2_0
 playfield:
 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
 X..............................X
 ...............................X
 .........XXX...XXX...XXX.......X
 ........XXXXXXXXXXXXXXXXX......X
 ..........X.....X.....X........X
 ..........X.....X.....X........X
 ..........X.....X.....X........X
 .........XXX...XXX...XXX.......X
 ...............................X
 X.............................XX
end
 _Playfield_Features  = %10010000
 goto __Play_Field_Selected bank1


__3x3_Field_2_1
 playfield:
 X.............................XX
 ...............................X
 ...............................X
 .....XXXXXXXXXXXX..............X
 .....XX........XX..............X
 .....X....XX....X..............X
 .....X...X..X...X..............X
 .....X..........X.....X........X
 .....XX........XX.....X........X
 .....X..........X.....X........X
 X....X..........X.....X.......XX
end
 _Playfield_Features  = %11011001 
 goto __Play_Field_Selected bank1

__3x3_Field_2_2
 playfield:
 X....X..........X.....X.......XX
 .....X..........X.....X........X
 .....XXXX....XXXX.....X........X
 .....X................X........X
 .....X................X........X
 .....X.........................X
 .....X...............XX........X
 .....XXXXXXXXXXXXXXXXXX........X
 ...............................X
 X..............................X
 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
end
 _Playfield_Features  = %10100000 
 goto __Play_Field_Selected bank1


   ;,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
   ;```````````````````````````````````````````````````````````````
   bank 5
   ;,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
   ;```````````````````````````````````````````````````````````````


   ;*****************************************
   ;  Effect ---  The next Round
   ;  Plane flys over, drops the latest New Thing
   ;  Player retursn to home field
   ;  stations filled with new data
__Next_Round_Effect
  
   _Round_Number_Bits012 = _Round_Number_Bits012 + 1 ; next Round!!
  temp4 = _Round_Number_Bits012 & %00000111

 if temp4 = 2 then score = score + 50000 : goto __Round_Two
 if temp4 = 3 then score = score +100000 : goto __Round_Three
 if temp4 = 4 then score - score +150000 : goto __Round_Four
 if temp4 = 5 then score = score +200000 : goto __Round_Five
 if temp4 = 6 then score = score +250000 : goto __Round_Six
 if temp4 > 6 then score = score +300000 : goto __Round_Seven



__Round_Two
 playfield:
 ...XXXX...............X...XXX...
 ...X..X.XXX.X.X.XXX.XXX.....X...
 ...XXX..X.X.X.X.X.X.X.X...XX....
 ...XX.X.XXX.XXX.X.X.XXX...XXXX..
 ................................
 ................................
 ................................
 ................................
 ................................
 ................................
 ................................
end
  
  _Station_Filled = %00000111 ; first 3 stations are filled, but locked as Fix has no key
  temp4 = rand&3 :  if temp4 > 2 then temp4 = 2 ; 3x3 rooms
  temp5 = rand&3 :  if temp5 > 2 then temp5 = 2
  temp5 = temp5 * 16 
  _Station_Contents_Pointers = temp4 + temp5 ; Sets the offset into the station data (what's inside) and the room where the Key is found  
 
 player1: ; the Shield is dropped
 %00111000
 %01111100
 %01111100
 %11101110
 %11010110
 %11101110
 %11111110
 %01111100
end
  
  goto __Got_Round



__Round_Three
 playfield:
 ...XXXX...............X...XXXX..
 ...X..X.XXX.X.X.XXX.XXX..... X..
 ...XXX..X.X.X.X.X.X.X.X....XXX..
 ...XX.X.XXX.XXX.X.X.XXX......X..
 ..........................XXXX..
 ................................
 ................................
 ................................
 ................................
 ................................
 ................................
end
  
  _Station_Filled = %00011111 ; first 5 stations are filled, but locked as Fix has no key
  temp4 = rand&3  ; 4x4 rooms 
  temp5 = rand&3   
  temp5 = temp5 * 16 
  _Station_Contents_Pointers = temp4 + temp5 ; Sets the offset into the station data (what's inside) and the room where the Key is found 
 
 player1:  ; Bow is dropped, need to find key again
 %00011000
 %00001100
 %00000110
 %00000110
 %00000110
 %00000110
 %00001100
 %00011000
end
  _Has_Key_Bit0{0}=0 ; Need to find the key at the start of each new arena

  goto __Got_Round


__Round_Four
 playfield:
 ...XXXX...............X...X..X..
 ...X..X.XXX.X.X.XXX.XXX...XXXXX.
 ...XXX..X.X.X.X.X.X.X.X......X..
 ...XX.X.XXX.XXX.X.X.XXX......X..
 ................................
 ................................
 ................................
 ................................
 ................................
 ................................
 ................................
end
  
  _Station_Filled = %00011111 ; first 5 stations are filled, but locked as Fix has no key
  temp4 = rand&3  ; 4x4 rooms 
  temp5 = rand&3   
  temp5 = temp5 * 16 
  _Station_Contents_Pointers = temp4 + temp5 ; Sets the offset into the station data (what's inside) and the room where the Key is found

 player1: ; Code Key A is dropped
 %00111110
 %01101100
 %01010100
 %01101110
 %01111110
 %01100100
 %01100100
 %00111110
end

  goto __Got_Round


__Round_Five
 playfield:
 ...XXXX...............X....XXX..
 ...X..X.XXX.X.X.XXX.XXX....XX...
 ...XXX..X.X.X.X.X.X.X.X......X..
 ...XX.X.XXX.XXX.X.X.XXX...XXXX..
 ................................
 ................................
 ................................
 ................................
 ................................
 ................................
 ................................
end
  
  _Station_Filled = %11111111 ; All stations are filled, but locked as Fix has no key
  temp4 = rand&3 +1  ; 5x5 rooms 
  temp5 = rand&3 +1   
  temp5 = temp5 * 16 
  _Station_Contents_Pointers = temp4 + temp5 ; Sets the offset into the station data (what's inside) and the room where the Key is found
 
 player1: ; Shock Proof Shield is dropped
 %01101011
 %01101011
 %01100111
 %01100001
 %01100111
 %01110011
 %01110011
 %00111110
end
  _Has_Key_Bit0{0}=0 ; need to find the Key at ethe briginnig i=of each new arena
  goto __Got_Round
  

__Round_Six
 playfield:
 ...XXXX...............X....XXX..
 ...X..X.XXX.X.X.XXX.XXX...XXX...
 ...XXX..X.X.X.X.X.X.X.X...X..X..
 ...XX.X.XXX.XXX.X.X.XXX...XXXX..
 ................................
 ................................
 ................................
 ................................
 ................................
 ................................
 ................................
end
  
  _Station_Filled = %11111111 ; All stations are filled, but locked as Fix has no key
  temp4 = rand&3 +1  ; 5x5 rooms 
  temp5 = rand&3 +1   
  temp5 = temp5 * 16 
  _Station_Contents_Pointers = temp4 + temp5 ; Sets the offset into the station data (what's inside) and the room where the Key is found
 
 player1: ; XG7 Laser Rifle is dropped
 %00000000
 %00000000
 %11000000
 %11101000
 %11111110
 %00100000
 %01110000
 %00000000
end
  
  goto __Got_Round


__Round_Seven
 playfield:
 ...XXXX...............X...XXXX..
 ...X..X.XXX.X.X.XXX.XXX......X..
 ...XXX..X.X.X.X.X.X.X.X.....X...
 ...XX.X.XXX.XXX.X.X.XXX....X....
 ................................
 ................................
 ................................
 ................................
 ................................
 ................................
 ................................
end
 
  _Station_Filled = %11111111 ; All stations are filled, but locked as Fix has no key
  temp4 = rand&3 + 1  ; 4x4 rooms 
  temp5 = rand&3 + 1  
  temp5 = temp5 * 16 
  _Station_Contents_Pointers = temp4 + temp5 ; Sets the offset into the station data (what's inside) and the room where the Key is found
 player1: ; Code B is dropped...you can finally WIN the game
 %00111100
 %01111110
 %01110110
 %00101010
 %00111110
 %01100110
 %01100110
 %00111100
end
  
  goto __Got_Round

__Got_Round

   

  ;************************************
  ; Anaimate the new Object Drop

Airplane
 player0:
 %00100000
 %00110000
 %10011000
 %01111111
 %11111110
 %10010000
 %00100000
 %00000000
end

   player0x = 20 : player0y = 44
   player1x = 200 : player1y = 48
   COLUP0 = $FA
   COLUP1 = $0C ; The dropped object is nice and bright
   COLUPF = $96
   _Ch0_Counter = 0

__Loop_Back_Round_Two
    _Ch0_Counter = _Ch0_Counter +1
    if _Ch0_Counter = 254 then goto __Setup_Round_two
    
    NUSIZ0 = $15 ; Wide
    COLUP0 = $FA
    COLUP1 = $00
    COLUPF = $96
            
    temp4 = _Ch0_Counter&1
    if temp4 then goto __Slow_Flight
    AUDV1 = 8
    AUDC1 = 3
    AUDF1 = 26
    player0x = player0x+1
    if _Ch0_Counter >126 then player1x = 88 : COLUP1 = $08 : player1y = player1y +1 

__Slow_Flight
   drawscreen
   goto __Loop_Back_Round_Two

__Setup_Round_two
  
 ; Return Player 0 to the Fox with Bow and enemy is blank
 player0:
 %10010000
 %10010000
 %11010100
 %01100010
 %01111010
 %01100010
 %00110100
 %00110000
end

 player1:
 %00000000
 %00000000
 %00000000
 %00000000
 %00000000
 %00000000
 %00000000
 %00000000
end
  

 playfield:
 XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
 XX......XX.....................X
 X...............................
 X...............................
 XX......XX......................
 XXXXXXXXXX......................
 X...............................
 X...............................
 X...............................
 X...............................
 XX.............................X
end
   _Present_Playfield = $00
   _Playfield_Features  = %00000000    	; starting field features reset
   
   pfscore1 = %11011011        		   ; all Eenmy lives restored
   if switchrightb then pfscore2 = %11111111 ; Start with full health when set to EASY
   
   player0x = 36 : player0y = 28
   player1x = 100 : player1y = 44
  
  _No_Enemy_Present_Bit3{3} = 1       	; No emey on restart screen
  _Bit0_Nova_Dead{0} = 0			; all enemies are back to life!!
  _Bit1_Bob_Dead{1} = 0
  _Bit2_Carl_Dead{2} = 0

   AUDV1 = 0 : AUDC1 = 0 : AUDF1 = 0  	; kill the background sound
   
   goto __Return_From_Effect bank1





   ;,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
   ;```````````````````````````````````````````````````````````````
   bank 6
   ;,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
   ;```````````````````````````````````````````````````````````````



   ;,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
   ;```````````````````````````````````````````````````````````````
   bank 7
   ;,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
   ;```````````````````````````````````````````````````````````````



   ;,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
   ;```````````````````````````````````````````````````````````````
   bank 8
   ;,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,
   ;```````````````````````````````````````````````````````````````