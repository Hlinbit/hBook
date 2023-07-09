@startuml
participant Object1
participant Object2

Object1 -> Object2: Message1
activate Object2
Object2 --> Object1: Message2
deactivate Object2
@enduml
