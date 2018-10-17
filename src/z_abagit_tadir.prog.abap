REPORT Z_ABAPGIT__TADIR.
tables: tadir .

*mehrere Systeme
SELECT-OPTIONS isrcsys FOR tadir-srcsystem DEFAULT ' '.
* Einzelsystem
*parameters: isrcsys like tadir-srcsystem.
parameters: nsrcsys like tadir-srcsystem default sy-sysid.
parameters: testmode as checkbox default 'X'.
parameters: custdev as checkbox default 'X'.


************************************************************************
data: istadir like tadir occurs 0 with header line.
data: itadir like tadir occurs 0 with header line .
data: nobj like sy-tabix .
************************************************************************
*
if testmode = 'X' .
  if sy-langu = 'D'.
    write:/ 'Testlauf. Keine Datenbank Änderungen durchgeführt.'.
    write:/.
  else.
    write:/ 'Test mode only. No database update will be performed.'.
    write:/.
  endif.
endif .


* collect relevant objects
* Source Tabelle auslesen istadir
clear istadir.

* mehrere Systeme
select * into table istadir from tadir where srcsystem in isrcsys.

if sy-dbcnt > 200000.
  if sy-langu = 'D'.
    WRITE: / 'Bitte selektieren sie weniger als 200.000 Einträge'.
    exit.
  else.
    WRITE: / 'Please select lower then 200.000 entries'.
    exit.
  endif.
endif.
* Einzelsystem
* select * into table istadir from tadir where srcsystem = isrcsys.

loop at istadir.

  if custdev = 'X'.
* nur Kundenentwicklungsklassen und keine generierten Objekte umsetzten

    if ( istadir-devclass(1) = 'Z' or istadir-devclass(1) = 'Y' )
*      and istadir-OBJ_NAME+2(3) ne isrcsys
      and istadir-OBJ_NAME+2(3) ne istadir-SRCSYSTEM
      and istadir-genflag ne 'X'.
      move-corresponding istadir to itadir.
      itadir-srcsystem = nsrcsys.
      append itadir .
      write:/ itadir-pgmid, itadir-object, itadir-obj_name,istadir-srcsystem.
    endif .
  else.
* alles umsetzen
*    if istadir-OBJ_NAME+2(3) ne isrcsys
    if istadir-OBJ_NAME+2(3) ne istadir-SRCSYSTEM
     and istadir-genflag ne 'X'.
      move-corresponding istadir to itadir.
      itadir-srcsystem = nsrcsys.
      append itadir .
      write:/ itadir-pgmid, itadir-object, itadir-obj_name, istadir-srcsystem.
    endif .
  endif.
endloop.


describe table itadir lines nobj .
if nobj = 0.
  if sy-langu = 'D'.
    write:/ 'Keine Objekte gefunden.' .
  else.
    write:/ 'No relevant objects found.' .
  endif.
  exit.
endif.

if testmode ne 'X' .
  update tadir from table itadir .
  if sy-langu = 'D'.
    WRITE: / 'Einträge von TADIR geändert:', sy-dbcnt.
  else.
    WRITE: / 'Number of entries for TADIR change:', sy-tfill.
  endif.
else.
  if sy-langu = 'D'.
    WRITE: / 'Einträge von TADIR werden geändert:', sy-tfill.
  else.
    WRITE: / 'Number of entries for TADIR will be change:', sy-tfill.
  endif.
endif .
