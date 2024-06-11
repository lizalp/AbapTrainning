REPORT ZR_FLIGHTS_LVAA.

INCLUDE ZR_FLIGHTS_TOP_LVAA.

INCLUDE ZR_FLIGHTS_F00_LVAA.

AT SELECTION-screen OUTPUT.

START-OF-SELECTION.


PERFORM f_inicio.


*&---------------------------------------------------------------------*
*& Include          ZR_FLIGHTS_TOP_LVAA
*&---------------------------------------------------------------------*

INCLUDE <icon>.

TABLES: scustom, sbook, sflight, scarr, spfli, sairport.

DATA:
  gt_scustom  TYPE scustom,
  gt_sbook    TYPE sbook,
  gt_sflight  TYPE sflight,
  gt_scarr    TYPE scarr,
  gt_spfli    TYPE spfli,
  gt_sairport TYPE sairport,

  v_msj       TYPE zdemsj.

TYPES: BEGIN OF ty_datos_combinados,
         scustom  TYPE scustom,
         sbook    TYPE sbook,
         sflight  TYPE sflight,
         scarr    TYPE scarr,
         spfli    TYPE spfli,
         sairport TYPE sairport,
       END OF ty_datos_combinados.

TYPES: tt_flight_detail TYPE TABLE OF zed_rpt_vuelos .

DATA it_flight_detail TYPE tt_flight_detail.

DATA:
      it_cuenta   TYPE TABLE OF ty_datos_combinados.

"ALV data
DATA : lt_fieldcat TYPE slis_t_fieldcat_alv,
       ls_fieldcat TYPE slis_fieldcat_alv,
       v_repid     LIKE sy-repid.

FIELD-SYMBOLS:
<fs_rpt_vuelos>            TYPE zed_rpt_vuelos.


SELECTION-SCREEN BEGIN OF BLOCK bg2 WITH FRAME TITLE TEXT-003.
PARAMETERS:
  p_clte2  TYPE scustom-id.
SELECT-OPTIONS:
  p_comaer FOR sbook-carrid, "Si quiero que un parametro sea obligatorio, coloco OBLIGATORY
  p_fecha FOR sbook-fldate.

SELECTION-SCREEN END OF BLOCK bg2.



*&---------------------------------------------------------------------*
*& Include          ZR_FLIGHTS_F00_LVAA
*&---------------------------------------------------------------------*

FORM f_inicio.

  PERFORM carga_datas USING p_clte2.

ENDFORM.

FORM carga_datas  USING    p_clte2.
* VALIDANDO QUE NO ESTE VACIO
  IF p_clte2 >= 1 .

    SELECT
      c~id,
      c~name,
      c~email,
      b~carrid,
      cr~carrname,
      b~connid,
      b~fldate,
      b~bookid,
      pl~airpfrom,
      ar~name,
      pl~airpto,
      ar2~name,
      f~price,
      f~currency

      INTO TABLE @it_flight_detail FROM scustom AS c

      INNER JOIN sbook AS b
      ON b~customid = c~id

      INNER JOIN scarr AS cr
      ON cr~carrid = b~carrid

      INNER JOIN spfli AS pl
      ON pl~carrid = b~carrid
      AND pl~connid = b~connid

      INNER JOIN sairport AS ar
      ON ar~id = pl~airpfrom

      INNER JOIN sairport AS ar2
      ON ar2~id = pl~airpto

      INNER JOIN sflight AS f
      ON f~carrid = b~carrid
      AND f~connid = b~connid
      AND f~fldate = b~fldate

      WHERE c~id = @p_clte2
      AND b~carrid IN @p_comaer
      AND b~fldate GE @p_fecha-low
      AND b~fldate LE @p_fecha-high.

    "" ELSEIF P_CLTE2 >= 1 AND P_COMAER NOT IN


  ELSE .

    SELECT
        c~id,
        c~name,
        c~email,
        b~carrid,
        cr~carrname,
        b~connid,
        b~fldate,
        b~bookid,
        pl~airpfrom,
        ar~name,
        pl~airpto,
        ar2~name,
        f~price,
        f~currency

      INTO TABLE @it_flight_detail FROM scustom AS c

      INNER JOIN sbook AS b
      ON b~customid = c~id

      INNER JOIN scarr AS cr
      ON cr~carrid = b~carrid

      INNER JOIN spfli AS pl
      ON pl~carrid = b~carrid
      AND pl~connid = b~connid

      INNER JOIN sairport AS ar
      ON ar~id = pl~airpfrom

      INNER JOIN sairport AS ar2
      ON ar2~id = pl~airpto

      INNER JOIN sflight AS f
      ON f~carrid = b~carrid
      AND f~connid = b~connid
      AND f~fldate = b~fldate

      WHERE b~carrid IN @p_comaer
      AND b~fldate GE @p_fecha-low
      AND b~fldate LE @p_fecha-high.


  ENDIF.

*         AND ( B~CARRID = @P_COMAER OR @P_COMAER IS INITIAL ) .

  IF it_flight_detail[] IS NOT INITIAL .

    SORT it_flight_detail BY nu_cliente fecha_vuelo nu_vuelo.
    PERFORM logica_de_negocio.

  ELSE.
    MESSAGE TEXT-002 TYPE 'E' DISPLAY LIKE 'E'.

  ENDIF.

ENDFORM.

FORM logica_de_negocio .

  PERFORM display_report.

ENDFORM.

FORM display_report .

*Field Catalogo
  CLEAR ls_fieldcat.
  ls_fieldcat-col_pos = 1.
  ls_fieldcat-fieldname = 'NU_CLIENTE'.
  ls_fieldcat-tabname = 'IT_FLIGHT_DETAIL'.
  ls_fieldcat-seltext_m = '# CLIENTE'.
  ls_fieldcat-key = 'X'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-col_pos = 2.
  ls_fieldcat-fieldname = 'NOM_CLIENTE'.
  ls_fieldcat-tabname = 'IT_FLIGHT_DETAIL'.
  ls_fieldcat-seltext_m = 'CLIENTE'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-col_pos = 3.
  ls_fieldcat-fieldname = 'EMAIL'.
  ls_fieldcat-tabname = 'IT_FLIGHT_DETAIL'.
  ls_fieldcat-seltext_m = 'EMAIL'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-col_pos = 4.
  ls_fieldcat-fieldname = 'ID_AEREO'.
  ls_fieldcat-tabname = 'IT_FLIGHT_DETAIL'.
  ls_fieldcat-seltext_m = 'COD. AEROLINEA'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-col_pos = 5.
  ls_fieldcat-fieldname = 'NOM_AEREO'.
  ls_fieldcat-tabname = 'IT_FLIGHT_DETAIL'.
  ls_fieldcat-seltext_m = 'AEROLINEA'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-col_pos = 6.
  ls_fieldcat-fieldname = 'NU_VUELO'.
  ls_fieldcat-tabname = 'IT_FLIGHT_DETAIL'.
  ls_fieldcat-seltext_m = '# VUELO'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-col_pos = 7.
  ls_fieldcat-fieldname = 'FECHA_VUELO'.
  ls_fieldcat-tabname = 'IT_FLIGHT_DETAIL'.
  ls_fieldcat-seltext_m = 'FECHA DE VUELO'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-col_pos = 8.
  ls_fieldcat-fieldname = 'RESERVACION'.
  ls_fieldcat-tabname = 'IT_FLIGHT_DETAIL'.
  ls_fieldcat-seltext_m = 'NUMERO DE RESERVACION'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-col_pos = 9.
  ls_fieldcat-fieldname = 'ID_AEREO_SAL'.
  ls_fieldcat-tabname = 'IT_FLIGHT_DETAIL'.
  ls_fieldcat-seltext_m = 'COD. AEROPUERTO SALIDA'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-col_pos = 10.
  ls_fieldcat-fieldname = 'NOM_AEREO_SAL'.
  ls_fieldcat-tabname = 'IT_FLIGHT_DETAIL'.
  ls_fieldcat-seltext_m = 'NOMBRE DEL AERO. SALIDA'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-col_pos = 11.
  ls_fieldcat-fieldname = 'ID_AEREO_DES'.
  ls_fieldcat-tabname = 'IT_FLIGHT_DETAIL'.
  ls_fieldcat-seltext_m = 'AEROPUERTO DESTINO'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-col_pos = 12.
  ls_fieldcat-fieldname = 'NOM_AEREO_DES'.
  ls_fieldcat-tabname = 'IT_FLIGHT_DETAIL'.
  ls_fieldcat-seltext_m = 'NOMBRE DEL AERO. DESTINO'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-col_pos = 13.
  ls_fieldcat-fieldname = 'PRECIO'.
  ls_fieldcat-tabname = 'IT_FLIGHT_DETAIL'.
  ls_fieldcat-seltext_m = 'PRECIO BOLETO'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CLEAR ls_fieldcat.
  ls_fieldcat-col_pos = 14.
  ls_fieldcat-fieldname = 'MONEDA'.
  ls_fieldcat-tabname = 'IT_FLIGHT_DETAIL'.
  ls_fieldcat-seltext_m = 'TIPO MONEDA LOCAL'.
  APPEND ls_fieldcat TO lt_fieldcat.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program = sy-repid
      it_fieldcat        = lt_fieldcat
    TABLES
      t_outtab           = it_flight_detail
    EXCEPTIONS
      program_error      = 1
      OTHERS             = 2.

  IF sy-subrc <> 0.
* Implement suitable error handling here
  ENDIF.
ENDFORM.