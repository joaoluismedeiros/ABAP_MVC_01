*&---------------------------------------------------------------------*
*& Report  ZJLM_MVC_LOCAL
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  zjlm_mvc_local.

INCLUDE zjlm_mvc_local_top.

INCLUDE zjlm_mvc_local_mdl.
INCLUDE zjlm_mvc_local_view.
INCLUDE zjlm_mvc_local_cntr.

DATA: o_control TYPE REF TO lcl_control.

INITIALIZATION.

  CREATE OBJECT: o_control.

START-OF-SELECTION.
  o_control->m_start_of_selection( ).
  o_control->m_call_screen( ).

  INCLUDE zjlm_mvc_local_f01.
