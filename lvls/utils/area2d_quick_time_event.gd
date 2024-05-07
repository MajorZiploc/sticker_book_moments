#Imagine this is the script of an area that prompts a QTE and kills whoever triggered if it fails
extends Area2D    
class_name Area2DQuickTimeEvent
# TODO: look up Area2D in that 219 nodes explained vid and make a hardcoded area2d in the game, then figure out how to code one
      
var QTE = QuickTimeEvent.new()  

var target #Stores whoever activated the QTE outside of functions

func _ready():  
    add_child(QTE) #Add the QTE to the scene  

    connect("body_entered", on_body_entered)#Detect any body that enters this area        

    QTE.duration = 2 #Change the duration cuz why not  
    QTE.connect("failed_input", qte_failed) #Connect the QTE to the method about failing
  
func on_body_entered(body):#the signal body_entered carries a parameter, so the function needs one too
    if body.has_property("health"):#Check if it has health  
        target = body#Save whoever entered in the variable
        QTE.start_qte()#Start the timer

func qte_failed(): #Called when the qte fails      
    if target != null: #Ensure the target still exists
        target.health = 0
