@startuml
start
:Initialize variables;
if (Condition) then (true)
  :Process A;
  if (Another Condition) then (true)
    :Process B;
  else (false)
    :Process C;
  endif
else (false)
  :Process D;
endif
stop
@enduml
