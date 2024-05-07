extends Node
class_name QuickTimeEvent
var active:bool #used to know if the qte is still accepting input  

@export var duration: float = 1.0  #Since it is an export, it appears in the Inspector so you can change it without editing the script  

@export var inputAction: String = "ui_accept" #Name of the action that will cause this QTE to succeed

signal successful_input #Will be emitted when this QTE is successful  
signal failed_input #The opposite

func start_qte(): #Run this to start the count down  
    var timer = get_tree().create_timer(duration) #Start a timer handled by the tree  
    timer.connect("timeout", end_qte) #Connect it  
    active = true

func end_qte(successful:bool = false):#The parameter will be false unless specified to be true  
    active = false #Stop accepting input   

    if successful:  
        emit_signal("succesful_input")     
    else:  
        emit_signal("failed_input") #Happens if the timer ends and the button was not pressed           

func _input(event):
    if active and event.is_action_pressed(inputAction):  
        end_qte(true)#The player pressed the button, the qte ends successfuly
