CLASS zas_rap_eml DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.

    DATA : out TYPE REF TO if_oo_adt_classrun_out.
    METHODS: read_eml.

ENDCLASS.



CLASS zas_rap_eml IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    me->out = out.

    read_eml( ).

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
    RESULT DATA(result)
    FAILED DATA(failed)
    REPORTED DATA(reported).

    out->write( result ).

*** Select Fields
    out->write( |\n>>>\tSELECT FIELDS\n\n| ).

    READ ENTITIES OF /dmo/r_travel_d "IN LOCAL MODE
    ENTITY travel
    FIELDS ( travelid customerid totalprice overallstatus )
    "WITH CORRESPONDING #( keys )
    WITH VALUE #( ( traveluuid = 'B81B1720EE8E8DDB18008F0AF489EEDD' )
                  ( traveluuid = 'B91B1720EE8E8DDB18008F0AF489EEDD' ) )
    RESULT result
    FAILED failed
    REPORTED reported.

    out->write( result ).

*** READ BY Association
    out->write( |\n>>>\tREAD BY Association\n\n| ).

    READ ENTITIES OF /dmo/r_travel_d "IN LOCAL MODE
    ENTITY booking BY \_travel
    ALL FIELDS
    "WITH CORRESPONDING #( keys )
    WITH VALUE #( ( bookinguuid = 'E82B1720EE8E8DDB18008F0AF489EEDD' ) )
    RESULT result
    LINK DATA(link)
    FAILED failed
    REPORTED reported.

    out->write( link )->write( |\n\n| )->write( result ).

  ENDMETHOD.

ENDCLASS.
