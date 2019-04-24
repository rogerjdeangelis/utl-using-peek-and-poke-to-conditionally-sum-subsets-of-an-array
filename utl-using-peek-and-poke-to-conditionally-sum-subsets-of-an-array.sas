Using peek and poke to conditionally sum slots in an array

This fast functionality is probably underused.

Basically this code mimics assembler instruction 'movelong'.
Movelong moves large blocks of storage from one address to another.
This is an efficient technique, probably diabled in EG on servers due to SAS negative enhancements..

SAS Forum
https://tinyurl.com/y5gl8j48
https://communities.sas.com/t5/SAS-Programming/How-to-conditionally-sum-up-certain-number-of-cells/m-p/553550

Novinosrin
https://communities.sas.com/t5/user/viewprofilepage/user-id/138205

*_                   _
(_)_ __  _ __  _   _| |_
| | '_ \| '_ \| | | | __|
| | | | | |_) | |_| | |_
|_|_| |_| .__/ \__,_|\__|
        |_|
;

data have;
  input slot1 slot2 slot3 number_of_slots_to_sum;
cards4;
1 2 3 3
1 2 3 2
;;;;
run;quit;

WORK.HAVE total obs=2
                              NUMBER_OF_
                               SLOTS_
  SLOT1    SLOT2    SLOT3      TO_SUM

    1        2        3           3
    1        2        3           2

*            _               _
  ___  _   _| |_ _ __  _   _| |_
 / _ \| | | | __| '_ \| | | | __|
| (_) | |_| | |_| |_) | |_| | |_
 \___/ \__,_|\__| .__/ \__,_|\__|
                |_|
;

WORK.WANT total obs=2
(1+2)
                                  NUMBER_OF_     BYTES_TO_    SUBSET_OF_  | RULES
                                    SLOTS_      MOVE_INTO_      SLOTS_    | Sum a variable number
Obs    SLOT1    SLOT2    SLOT3      TO_SUM        SUBSET        SUMMED    | of slots
                                                                          |
 1       1        2        3           3            24             6      | (1+2+3) =6
 2       1        2        3           2            16             3      | (1+2)   =3

*
 _ __  _ __ ___   ___ ___  ___ ___
| '_ \| '__/ _ \ / __/ _ \/ __/ __|
| |_) | | | (_) | (_|  __/\__ \__ \
| .__/|_|  \___/ \___\___||___/___/
|_|
;

data want;

  set have ;

  array input_slots(*) slot: ;
  array subset_slots(999) _temporary_;   * store the subset to sum ;

  adr_first_input_slot      = addrlong(input_slots(1))   ;
  adr_first_subset_slot     = addrlong(subset_slots(1))  ;
  bytes_to_move_into_subset = number_of_slots_to_sum * 8 ;  * amout of bytes to move in one operation up to 32k bytes;

  call pokelong(
          peekclong(
          adr_first_input_slot, bytes_to_move_into_subset)  /* address of block of storage to move */
          ,adr_first_subset_slot                             /* move to address                    */
          ,bytes_to_move_into_subset                          /* betes to move up to 32k           */
          );

          subset_of_slots_summed=sum(of subset_slots(*));
          call missing(of subset_slots(*));
drop adr_:;
run;quit;


