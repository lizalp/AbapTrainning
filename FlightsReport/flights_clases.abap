    "  create object lo_table.
 "   call method lo_table
    try.
      cl_salv_table=>factory(
        IMPORTING
          r_salv_table   =   lo_table                         " Basis Class Simple ALV Tables
        CHANGING
          t_table        =  it_final
      ).
      catch cx_salv_msg.
      endtry.
       "*************** Autoadjustar columnas en el ALV ******
    lo_columns = lo_table->get_columns( ).


    LOOP AT lo_strucdescr->components INTO ls_components.
      cont2 = cont.
      CALL METHOD get_text
        EXPORTING
          pnumber = cont2
        IMPORTING
          ptext   = stext.

      IF cont EQ 1.
        CALL METHOD set_fieldcat
          EXPORTING
            col_pos     = cont
            fieldname   = ls_components-name
            tabname     = 'it_final'
            headercol   = stext
            key         = 'X'
          CHANGING
            lt_fieldcat = lt_fieldcat.
        gr_column  ?= lo_columns->get_column( ls_components-name ).
      ELSE.
        CALL METHOD set_fieldcat
          EXPORTING
            col_pos     = cont
            fieldname   = ls_components-name
            tabname     = 'it_final'
            headercol   = stext
            key         = ''
          CHANGING
            lt_fieldcat = lt_fieldcat.
        gr_column  ?= lo_columns->get_column( ls_components-name ).

      ENDIF.

      cont = cont + 1.
    ENDLOOP.

    lo_columns->set_optimize( abap_true ).

    "o you use a FM called REUSE_ALV_GRID_DISPLAY.
    "There is a exporting parameter called I_callback_user_command.
    "In this parameter you have to set the form name of your program


    lo_event = lo_table->get_event( ).
    set handler me->handler_double_click for lo_event.

        "************ Guardar variantes en el ALV ***********
    "obj que nos regresa el layout
    ls_key-report = sy-repid.
    lo_layout = lo_table->get_layout( ).
    lo_layout->set_key( ls_key ).
    "permitir guardar la variante
    lo_layout->set_save_restriction( if_salv_c_layout=>restrict_none ).

    "******** Activar barra de herramientas SALV (botones) *********************
    "activamos todas las funcionalidades de mi alv
    lo_functions = lo_table->get_functions( ).
*    lo_functions->set_default( abap_true ).
    lo_functions->set_all( abap_true ).

    it_flight[] = it_final[].
    lo_table->display( ).
  ENDMETHOD.

  METHOD handler_2click.
    READ TABLE it_final INTO wa_sflight INDEX rs_selfield-tabindex.

    SUBMIT zr_flights_lvaa
    WITH p_clte2 = wa_sflight-id
    WITH p_connid = wa_sflight-connid

    AND RETURN.

  ENDMETHOD.

  METHOD handler_double_click.
    data msj type string.


    if column eq 'ID' or column eq 'CONNID'.
      READ TABLE it_flight INTO wa_sflight  INDEX row.
*      msj = '|Columna: ' && wa_sflight-id &&  '| Fila: ' && wa_sflight-connid.
*       MESSAGE msj type 'I'.
      SUBMIT zr_flights_lvaa
      WITH p_clte2 = wa_sflight-id
      WITH p_connid = wa_sflight-connid
      AND RETURN.

      else.
        msj = 'Invalido. Da clic en la col ID del cliente que deseas ver mayor detalle'.
       MESSAGE msj type 'I'.

      ENDIF.
  ENDMETHOD.

ENDCLASS.