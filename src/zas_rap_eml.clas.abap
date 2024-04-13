CLASS zas_rap_eml DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA : out TYPE REF TO if_oo_adt_classrun_out.

    METHODS:
      read_eml,
      modify_create,
      modify_update,
      modify_delete,
      modify_execute,
      modify_augment.

ENDCLASS.



CLASS zas_rap_eml IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    me->out = out.

*    read_eml( ).
*    modify_create( ).
*    modify_update( ).
*    modify_delete( ).
*    modify_execute( ).
*    modify_augment( ).

  ENDMETHOD.

  METHOD read_eml.
*--------------------------------------------------------------------*
*   READ
*--------------------------------------------------------------------*
    out->write( |-------------\tREAD\t-------------\n| ).

*** All Fields
    out->write( |>>>\tALL FIELDS\n\n| ).

    READ ENTITIES OF /dmo/r_travel_d "IN LOCAL MODE
    ENTITY travel
    ALL FIELDS WITH "CORRESPONDING #( keys )
    VALUE #( ( traveluuid = 'BB1B1720EE8E8DDB18008F0AF489EEDD' )
             ( traveluuid = 'BE1B1720EE8E8DDB18008F0AF489EEDD' )
             ( traveluuid = 'C01B1720EE8E8DDB18008F0AF489EEDD' ) )
    RESULT DATA(lt_result)
    FAILED DATA(lt_failed)
    REPORTED DATA(lt_reported).

    out->write( lt_result ).

*** Select Fields
    out->write( |\n>>>\tSELECT FIELDS\n\n| ).

    READ ENTITIES OF /dmo/r_travel_d "IN LOCAL MODE
    ENTITY travel
    FIELDS ( travelid customerid totalprice overallstatus )
    "WITH CORRESPONDING #( keys )
    WITH VALUE #( ( traveluuid = 'B81B1720EE8E8DDB18008F0AF489EEDD' )
                  ( traveluuid = 'B91B1720EE8E8DDB18008F0AF489EEDD' ) )
    RESULT lt_result
    FAILED lt_failed
    REPORTED lt_reported.

    out->write( lt_result ).

*** READ BY Association
    out->write( |\n>>>\tREAD BY Association\n\n| ).

    READ ENTITIES OF /dmo/r_travel_d "IN LOCAL MODE
    ENTITY booking BY \_travel
    ALL FIELDS
    "WITH CORRESPONDING #( keys )
    WITH VALUE #( ( bookinguuid = 'E82B1720EE8E8DDB18008F0AF489EEDD' ) )
    RESULT lt_result
    LINK DATA(lt_link)
    FAILED lt_failed
    REPORTED lt_reported.

    out->write( lt_link )->write( |\n\n| )->write( lt_result ).

  ENDMETHOD.

  METHOD modify_create.

*--------------------------------------------------------------------*
*   MODIFY
*--------------------------------------------------------------------*
    out->write( |\n\n-------------\tMODIFY\t-------------\n\n| ).

    DATA: lt_create      TYPE TABLE FOR CREATE /dmo/r_travel_d,
          lt_create_auto TYPE TABLE FOR CREATE /dmo/r_travel_d.

    SELECT SINGLE airlineid, connectionid, flightdate FROM /dmo/i_flight INTO @DATA(ls_flight).

*** Create Entity
    out->write( |>>>\tCREATE Entity\n\n| ).

    lt_create = VALUE #( ( %cid        = 'create_new_travel'
                           %is_draft   = if_abap_behv=>mk-off
                           customerid  = '1'
                           agencyid    = '70006'
                           begindate   = ls_flight-flightdate
                           enddate     = ls_flight-flightdate
                           description = 'Work Travel' ) ).

    MODIFY ENTITIES OF /dmo/r_travel_d
    ENTITY travel
    CREATE FIELDS ( customerid agencyid begindate enddate description )
    WITH lt_create
    MAPPED DATA(lt_mapped)
    FAILED DATA(lt_failed)
    REPORTED DATA(lt_reported).

    out->write( lt_mapped ).

    COMMIT ENTITIES
    IN SIMULATION MODE " The save sequence is executed without actually saving any data.
                       " The methods finalize, check_before_save, and cleanup_finalize are executed,
                       " but the methods adjust_numbers, save and cleanup are not.
    RESPONSE OF /dmo/r_travel_d
    FAILED DATA(lt_failed_commit)
    REPORTED DATA(lt_reported_commit).


**  Reset transaction buffer
*   ROLLBACK ENTITIES.


*** CREATE Entity with Auto-Fill CID
    out->write( |\n>>>\tCREATE Entity and Child\n\n| ).

    lt_create_auto = VALUE #( ( %is_draft   = if_abap_behv=>mk-off
                                customerid  = '1'
                                agencyid    = '70006'
                                begindate   = ls_flight-flightdate
                                enddate     = ls_flight-flightdate
                                description = 'Work Travel' ) ).

    MODIFY ENTITIES OF /dmo/r_travel_d
    ENTITY travel
    CREATE AUTO FILL CID FIELDS ( customerid agencyid begindate enddate description )
    WITH lt_create_auto
    MAPPED lt_mapped
    FAILED lt_failed
    REPORTED lt_reported.

    out->write( lt_mapped ).

    COMMIT ENTITIES
    IN SIMULATION MODE
    RESPONSE OF /dmo/r_travel_d
    FAILED lt_failed_commit
    REPORTED lt_reported_commit.


*** CREATE Entity and Child
    out->write( |\n>>>\tCREATE Entity and Child\n\n| ).

    MODIFY ENTITIES OF /dmo/r_travel_d
    ENTITY travel
    CREATE FIELDS ( customerid agencyid begindate enddate description ) WITH lt_create
    CREATE BY \_booking FIELDS ( customerid airlineid connectionid flightdate )
    WITH VALUE #( ( %cid_ref = 'create_new_travel'
                    %target  = VALUE #( ( %cid         = 'create_booking_1'
                                          %is_draft    = if_abap_behv=>mk-off
                                          customerid   = '1'
                                          airlineid    = ls_flight-airlineid
                                          connectionid = ls_flight-connectionid
                                          flightdate   = ls_flight-flightdate )
                                        ( %cid         = 'create_booking_2'
                                          %is_draft    = if_abap_behv=>mk-off
                                          customerid   = '2'
                                          airlineid    = ls_flight-airlineid
                                          connectionid = ls_flight-connectionid
                                          flightdate   = ls_flight-flightdate + 10 ) ) ) )
     MAPPED lt_mapped
     FAILED lt_failed
     REPORTED lt_reported.

    out->write( lt_mapped ).

    COMMIT ENTITIES
    IN SIMULATION MODE
    RESPONSE OF /dmo/r_travel_d
    FAILED lt_failed_commit
    REPORTED lt_reported_commit.

  ENDMETHOD.

  METHOD modify_update.

*--------------------------------------------------------------------*
*   MODIFY
*--------------------------------------------------------------------*
    out->write( |\n\n-------------\tMODIFY\t-------------\n\n| ).

*** Update Entity
    out->write( |>>>\tUPDATE Entity\n\n| ).

    MODIFY ENTITIES OF /dmo/r_travel_d
    ENTITY booking
    UPDATE FIELDS ( bookingstatus )
    WITH VALUE #( ( bookinguuid   = 'E92B1720EE8E8DDB18008F0AF489EEDD'
                    %is_draft     = if_abap_behv=>mk-off "choice between modifying draft or active instances
                    bookingstatus = 'A' )
                  ( bookinguuid   = 'EA2B1720EE8E8DDB18008F0AF489EEDD'
                    %is_draft     = if_abap_behv=>mk-off
                    bookingstatus = 'A' ) )
    MAPPED DATA(lt_mapped)
    FAILED DATA(lt_failed)
    REPORTED DATA(lt_reported).

    out->write( lt_mapped ).

    COMMIT ENTITIES
    IN SIMULATION MODE
    RESPONSE OF /dmo/r_travel_d
    FAILED DATA(lt_failed_commit)
    REPORTED DATA(lt_reported_commit).

  ENDMETHOD.

  METHOD modify_delete.

*--------------------------------------------------------------------*
*   MODIFY
*--------------------------------------------------------------------*
    out->write( |\n\n-------------\tMODIFY\t-------------\n\n| ).

*** Delete Entity
    out->write( |>>>\tDELETE Entity\n\n| ).

    MODIFY ENTITIES OF /dmo/r_travel_d
    ENTITY travel
    DELETE FROM VALUE #( ( traveluuid = 'C01B1720EE8E8DDB18008F0AF489EEDD'
                           %is_draft  = if_abap_behv=>mk-off ) )
    FAILED DATA(lt_failed)
    REPORTED DATA(lt_reported).

    COMMIT ENTITIES
    IN SIMULATION MODE
    RESPONSE OF /dmo/r_travel_d
    FAILED DATA(lt_failed_commit)
    REPORTED DATA(lt_reported_commit).

  ENDMETHOD.

  METHOD modify_execute.

*--------------------------------------------------------------------*
*   MODIFY
*--------------------------------------------------------------------*
    out->write( |\n\n-------------\tMODIFY\t-------------\n\n| ).

*** Execute Action
    out->write( |>>>\tExecute Action / Function\n\n| ).

    READ ENTITIES OF /dmo/r_travel_d
    ENTITY booking BY \_travel
    ALL FIELDS WITH VALUE #( ( bookinguuid = 'E82B1720EE8E8DDB18008F0AF489EEDD' ) )
    RESULT DATA(lt_travel)
    FAILED DATA(lt_failed)
    REPORTED DATA(lt_reported).


    MODIFY ENTITIES OF /dmo/r_travel_d
    ENTITY travel
    EXECUTE accepttravel
    FROM CORRESPONDING #( lt_travel )
    RESULT DATA(lt_result)
    FAILED lt_failed
    REPORTED lt_reported.

    out->write( lt_result ).

  ENDMETHOD.

  METHOD modify_augment.

*--------------------------------------------------------------------*
*   MODIFY
*--------------------------------------------------------------------*
    out->write( |\n\n-------------\tMODIFY\t-------------\n\n| ).
*** Augmenting
    out->write( |>>>\tAugmenting\n\n| ).

  ENDMETHOD.

ENDCLASS.
