*&---------------------------------------------------------------------*
*&  Include           ZJLM_MVC_LOCAL_VIEW
*&---------------------------------------------------------------------*
CLASS lcl_view DEFINITION.

  PUBLIC SECTION.
    TYPES: BEGIN OF yt_tela_inicial,
          companhia TYPE typ_r_carrid,
          voo TYPE typ_r_connid,
       END OF yt_tela_inicial.

    TYPES: BEGIN OF y_model,
            okcode       TYPE okcode,
            o_container  TYPE REF TO cl_gui_custom_container,
            o_grid       TYPE REF TO cl_gui_alv_grid,
            tela_sel     TYPE yt_tela_inicial,
            it_relatorio TYPE spfli_tab,
           END OF y_model.

    DATA: w_model TYPE y_model.

    METHODS m_search_data.

    METHODS m_set_model
          IMPORTING
            i_model TYPE REF TO lcl_model .

    METHODS m_set_companhia
          IMPORTING
            i_companhia TYPE typ_r_carrid.
    METHODS m_set_voo
          IMPORTING
            i_voo TYPE typ_r_connid .
    METHODS m_build_alv
          IMPORTING
            i_container TYPE c.

  PRIVATE SECTION.

    DATA o_model TYPE REF TO lcl_model.

    METHODS m_finalizar_objetos.

    METHODS m_set_toolbar
      CHANGING
        ch_toolbar TYPE ui_functions .
    METHODS m_set_fieldcat
      RETURNING
        value(r_return) TYPE lvc_t_fcat .
    METHODS m_formata_campos
      IMPORTING
        i_campo   TYPE lvc_fname
        i_nome    TYPE lvc_fname OPTIONAL
        i_visivel TYPE lvc_noout
        i_ordem   TYPE lvc_colpos OPTIONAL
        i_field   TYPE lvc_fname OPTIONAL
      CHANGING
        ch_fieldcat TYPE lvc_t_fcat .

ENDCLASS.                    "lcl_model DEFINITION

*----------------------------------------------------------------------*
*       CLASS lcl_model IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS lcl_view IMPLEMENTATION.

  METHOD m_search_data.

    o_model->m_set_companhia( w_model-tela_sel-companhia ).
    o_model->m_set_voo( w_model-tela_sel-voo ).

    w_model-it_relatorio = o_model->m_executar( ).

  ENDMETHOD.                    "m_search_data
  METHOD m_set_companhia.

    w_model-tela_sel-companhia = i_companhia.

  ENDMETHOD.                    "m_set_cliente

  METHOD m_set_voo.

    w_model-tela_sel-voo = i_voo.

  ENDMETHOD.                    "m_set_data

  METHOD m_set_model.

    o_model = i_model.

  ENDMETHOD.                    "m_set_model

  METHOD m_build_alv.

    DATA: itl_fieldcat TYPE lvc_t_fcat,
          itl_toolbar  TYPE ui_functions.

    DATA: wal_alv_layout TYPE lvc_s_layo,
          wal_variant    TYPE disvariant.

    CLEAR: wal_alv_layout, wal_variant, itl_fieldcat.

    IF w_model-o_grid IS NOT INITIAL.
      m_finalizar_objetos( ).
    ELSE.
      CREATE OBJECT w_model-o_container
        EXPORTING
          container_name = i_container.

      CREATE OBJECT w_model-o_grid
        EXPORTING
          i_parent = w_model-o_container.
    ENDIF.

    SET HANDLER: o_model->m_handle_data_changed FOR w_model-o_grid,
                 o_model->m_handle_click        FOR w_model-o_grid,
                 o_model->m_handle_toolbar      FOR w_model-o_grid,
                 o_model->m_handle_user_command FOR w_model-o_grid.

    m_set_toolbar( CHANGING ch_toolbar = itl_toolbar ).
    itl_fieldcat = m_set_fieldcat( ).

    wal_variant-report   = sy-cprog.
    wal_variant-username = sy-uname.

    wal_alv_layout-cwidth_opt = 'X'.
    wal_alv_layout-sel_mode   = 'A'.
    wal_alv_layout-no_merging = 'X'.
    wal_alv_layout-numc_total = 'X'.
    wal_alv_layout-zebra      = 'X'.

    CALL METHOD w_model-o_grid->set_table_for_first_display
      EXPORTING
        is_variant                    = wal_variant
        is_layout                     = wal_alv_layout
      CHANGING
        it_outtab                     = w_model-it_relatorio
        it_fieldcatalog               = itl_fieldcat
      EXCEPTIONS
        invalid_parameter_combination = 1
        program_error                 = 2
        too_many_lines                = 3
        OTHERS                        = 4.


  ENDMETHOD.                    "m_build_alv

  METHOD m_finalizar_objetos.

    w_model-o_grid->finalize( ).
    w_model-o_grid->free( ).

    w_model-o_container->finalize( ).
    w_model-o_container->free( ).

    CLEAR: w_model-o_container, w_model-o_grid.

  ENDMETHOD.                    "m_finalizar_objetos

  METHOD m_set_toolbar.
    DATA : wal_toolbar   TYPE ui_func.

    wal_toolbar = cl_gui_alv_grid=>mc_fc_loc_append_row .
    APPEND wal_toolbar TO ch_toolbar.

    wal_toolbar = cl_gui_alv_grid=>mc_fc_loc_insert_row .
    APPEND wal_toolbar TO ch_toolbar.

    wal_toolbar = cl_gui_alv_grid=>mc_fc_loc_delete_row .
    APPEND wal_toolbar TO ch_toolbar.

    wal_toolbar = cl_gui_alv_grid=>mc_fc_loc_copy .
    APPEND wal_toolbar TO ch_toolbar.

    wal_toolbar = cl_gui_alv_grid=>mc_fc_loc_copy_row .
    APPEND wal_toolbar TO ch_toolbar.

    wal_toolbar = cl_gui_alv_grid=>mc_fc_loc_cut .
    APPEND wal_toolbar TO ch_toolbar.

    wal_toolbar = cl_gui_alv_grid=>mc_fc_loc_undo.
    APPEND wal_toolbar TO ch_toolbar.

    wal_toolbar = cl_gui_alv_grid=>mc_fc_loc_paste.
    APPEND wal_toolbar TO ch_toolbar.

    wal_toolbar = cl_gui_alv_grid=>mc_fc_loc_paste_new_row.
    APPEND wal_toolbar TO ch_toolbar.

    wal_toolbar = cl_gui_alv_grid=>mc_fc_select_all.
    APPEND wal_toolbar TO ch_toolbar.

    wal_toolbar = cl_gui_alv_grid=>mc_fc_graph .
    APPEND wal_toolbar TO ch_toolbar.

    wal_toolbar = cl_gui_alv_grid=>mc_fc_detail .
    APPEND wal_toolbar TO ch_toolbar.

    wal_toolbar = cl_gui_alv_grid=>mc_fc_info .
    APPEND wal_toolbar TO ch_toolbar.

    wal_toolbar = cl_gui_alv_grid=>mc_fc_refresh .
    APPEND wal_toolbar TO ch_toolbar.


  ENDMETHOD.                    "m_set_toolbar

  METHOD m_set_fieldcat.

    FIELD-SYMBOLS: <fsl_relatorio> TYPE spfli.

    CALL FUNCTION 'LVC_FIELDCATALOG_MERGE'
      EXPORTING
        i_structure_name       = 'SPFLI'
      CHANGING
        ct_fieldcat            = r_return
      EXCEPTIONS
        inconsistent_interface = 1
        program_error          = 2
        OTHERS                 = 3.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
           WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ELSE.
      SORT r_return BY fieldname.
    ENDIF.

    m_formata_campos( EXPORTING i_campo = 'CONNID'     i_nome = 'Companhia' i_visivel = ' ' i_ordem = 1  CHANGING ch_fieldcat = r_return ).

  ENDMETHOD.                    "m_set_fieldcat_header

  METHOD m_formata_campos.

    FIELD-SYMBOLS: <fsl_fieldcat> TYPE lvc_s_fcat.

    READ TABLE ch_fieldcat ASSIGNING <fsl_fieldcat> WITH KEY fieldname = i_campo BINARY SEARCH.

    IF sy-subrc IS INITIAL.
      IF i_campo EQ 'CONNID' AND i_nome IS NOT INITIAL.
        <fsl_fieldcat>-hotspot = 'X'.
      ENDIF.

      <fsl_fieldcat>-reptext   = i_nome.
      <fsl_fieldcat>-scrtext_l = i_nome.
      <fsl_fieldcat>-scrtext_m = i_nome.
      <fsl_fieldcat>-scrtext_s = i_nome.
      <fsl_fieldcat>-no_out    = i_visivel.
      <fsl_fieldcat>-col_pos   = i_ordem.

    ENDIF.


  ENDMETHOD.                    "m_formata_campos

ENDCLASS.                    "lcl_model IMPLEMENTATION
