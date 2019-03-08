-----------------------------------------------------------------------------------------
--
-- workout.lua
--[[
Workout routine tempplates 
Select Mass vs. Endurance
Timer for rest time
Remembers weights for exercises 
Randomize full body workout
Pick full body workout
Pictures of how to do the exercise
Motivating pics/words
--]]
-----------------------------------------------------------------------------------------

require "math"
local widget = require("widget")

--create display
display.setStatusBar(display.HiddenStatusBar)

orientation = {
	default = "landscape",
	supported = { "portrait", "landscapeLeft", "landscapeRight"}
}


--declare variables

mass 				= true --mass = false for endurance
RestTimer 			= 0

BicepExercises 		= {'Hammer Curls','Sitting Isolated Curl','Bar Curl','Free Weight Curl','One Arm Bench Curl',"40's"} --len() = 6
TricepExercises 	= {'Overhead Press','Skullcrusher','Triceps extention','Dips','Closed-Grip Bench','Cable Pulldown'}
ChestExercises 		= {'Free Weights Bench','Inclined Bench','Inclined Free Weights','Flat Bench','Declined Bench','Cable Flys'}
ShoulderExercises 	= {'Shoulder Press', 'Lateral Raises', 'Military Press', 'Arnold Press', 'Cable flys','Upright Row', 'Font Raises'}
BackExercises 		= {'Pull Ups','Australian PullUp','Seated Row','Single Arm Row','Lat Pulldown','Close Grip Pulldown','Straight Arm Cable Pull-Down','Bent Over Row'}
LegExercises 		= {'Squat','Front Squat','Deadlift','Leg Extensions','Lunges','Leg Press','Calf Raises'}
AllExercisesTable 	= {BicepExercises,TricepExercises,ChestExercises,ShoulderExercises,BackExercises,LegExercises}
saveData = 3

--weights = {} -- list of arrays : [exercise,weight] read/write from file
font 				= "Britannic Bold"
invis 		 		= 0 -- set to 1 for visible hitboxes
ButtonWidth			= 120
ButtonHeight 		= 35
screen 				= 0		--Keeps track of which screen menus the user is on

--image 	= display.newImageRect("backgrounds/bg.jpg", display.contentWidth+100, display.contentHeight) 
image 	= display.newImageRect("backgrounds/bg.jpg", display.contentWidth+100, display.contentHeight) 
image.x = display.contentCenterX
image.y = display.contentCenterY


function menu()
	screen 	  = 1
	print("Screen = " .. screen)
	FullBodyText	 = display.newText("Full-Body"	,display.contentWidth*1/10  , display.contentHeight*4/10, font,30)
	OneMuscle 		 = display.newText("One Muscle"	,display.contentWidth*5/10  , display.contentHeight*4/10, font,30)
	TwoMuscle 		 = display.newText("Two Muscle"	,display.contentWidth*9/10  , display.contentHeight*4/10, font,30)



	FullBodyButton 	 = display.newImageRect("Select.gif",ButtonWidth,ButtonHeight)
	FullBodyButton.x = FullBodyText.x
	FullBodyButton.y = FullBodyText.y + FullBodyButton.height

	OneMuscleButton   = display.newImageRect("Select.gif",ButtonWidth,ButtonHeight)
	OneMuscleButton.x = OneMuscle.x
	OneMuscleButton.y = OneMuscle.y + OneMuscleButton.height

	TwoMuscleButton   = display.newImageRect("Select.gif",ButtonWidth,ButtonHeight)
	TwoMuscleButton.x = TwoMuscle.x
	TwoMuscleButton.y = TwoMuscle.y + TwoMuscleButton.height

	CreateMenuButton()
	-- Create the touch event handler function 
	OneMuscleButton :addEventListener("tap", OneMuscleButtonHandler)
	TwoMuscleButton :addEventListener("tap", TwoMuscleButtonHandler)
	FullBodyButton 	:addEventListener("tap", FullBodyButtonHandler )
end


function removeMenu()
	--remove menu objects
	FullBodyText	:removeSelf()
	OneMuscle		:removeSelf()
	TwoMuscle 		:removeSelf()
	FullBodyButton 	:removeSelf()
	OneMuscleButton	:removeSelf()
	TwoMuscleButton	:removeSelf()
	RemoveMenuButton()
end


function GoToMenuListener()
	if screen == 1 then
		removeMenu()
	elseif screen == 2 then
		if workout == 3 then
			removeFullbody()
		elseif workout == 2 then
			--removeTwoMuscle()
		elseif workout == 1 then
			removeOneMuscleMenu()
		end
		print("Remove Fullbody/OneMuscle/TwoMuscle screen")

	elseif screen == 3 then
		removeOneMuscleExercises()

	else 
		print("Not sure if needed")
	end
	RemoveMenuButton()
	menu()
end



function CreateMenuButton()
	MenuButton   = display.newImageRect("menu button.gif",ButtonWidth,ButtonHeight)
	MenuButton.x = display.contentWidth*9/10
	MenuButton.y = display.contentHeight*1/10
	MenuButton:addEventListener("tap", GoToMenuListener)
end

function RemoveMenuButton()
	MenuButton:removeSelf()
end

function FullBodyWorkoutMenu()
	screen = 2
	--
	WriteToFile()
	ReadFile()
	--
	print("Screen = "..screen)
	print('randomize or not')
	CreateMenuButton()
	FullBodyText = display.newText("Full Body Workout",display.contentWidth/2, display.contentHeight*1/10, font,25)

	Exercises = {}
	ExercisesText = {}
	ExerciseTextBox = {}
	for i=1,6 do
		Exercises[i] 	 = AllExercisesTable[i][math.random(table.getn(AllExercisesTable[i]))] --Goes through the array and picks a random exercise
		ExercisesText[i] = display.newText(Exercises[i],display.contentWidth*((1 + 4*(math.floor((i-1)/2)))/10),display.contentHeight*(((i%2)*(-7))+10)/15, font,15) 
		ExercisesText[i]:setFillColor( 0, 0, 0 )
		
		ExerciseTextBox[i]		= native.newTextBox( ExercisesText[i].x, ExercisesText[i].y + 25, 175, 20 )
		ExerciseTextBox[i].text = "Enter the weight that you lifted."
		ExerciseTextBox[i].isEditable = true
		ExerciseTextBox[i]:addEventListener( "userInput", ExerciseTextBoxListener )
	end
end

function removeFullbody()
	FullBodyText:removeSelf()
	for i=1,6 do
		ExercisesText[i]:removeSelf()
		ExerciseTextBox[i]:removeSelf()
	end
end
function removeOneMuscleMenu()
	WhichMuscleText:removeSelf()
	for i=1,6 do
		MuscleGroupsDisplayText[i]	:removeSelf()
		MuscleGroupsJPG[i]			:removeSelf()
	end
end

function removeOneMuscleExercises()
	for i=1,6 do
		OneMuscleExercisesJPG[i]	:removeSelf()
		OneMuscleExercisesText[i]	:removeSelf()
	end
end


function OneMuscleWorkoutMenu2()
	screen = 2
	print("Screen = "..screen)
	print('Which muscle')
	CreateMenuButton()

	WhichMuscleText = display.newText("Which muscle group?",display.contentWidth/2, display.contentHeight*1/10, font,25)

	MuscleGroupsDisplayText = {}
	MuscleGroupsArray 		= {'Biceps','Triceps','Chest','Shoulders','Back','Legs'}
	MuscleGroupsJPG			= {}

	for i=1,6 do	
		MuscleGroupsDisplayText[i] 	= display.newText(MuscleGroupsArray[i],display.contentWidth*((1 + 4*(math.floor((i-1)/2)))/10),display.contentHeight*(((i%2)*(-7))+10)/15 - 5, font,15) 
		MuscleGroupsJPG[i]			= display.newImageRect("backgrounds/Muscle Groups/" .. MuscleGroupsArray[i] .. '.jpg', 125,100) 
		MuscleGroupsJPG[i].x 		= display.contentWidth*((1 + 4*(math.floor((i-1)/2)))/10)
		MuscleGroupsJPG[i].y 		= display.contentHeight*(((i%2)*(-7))+10)/15 + 55

	end
	MuscleGroupsJPG[1]:addEventListener( "tap", BicepsWorkoutListener)
	MuscleGroupsJPG[2]:addEventListener( "tap", TricepsWorkoutListener)
	MuscleGroupsJPG[3]:addEventListener( "tap", ChestWorkoutListener)
	MuscleGroupsJPG[4]:addEventListener( "tap", ShouldersWorkoutListener)
	MuscleGroupsJPG[5]:addEventListener( "tap", BackWorkoutListener)
	MuscleGroupsJPG[6]:addEventListener( "tap", LegsWorkoutListener)
end

local function onRowRender( event )
	local row = event.row

	local rowHeight = row.contentHeight
	local rowWidth  = row.contentWidth

	local rowTitle  = display.newText(row,"Row " .. row.index, 0, 0, nil, 14)
	--local rowTitle  = display.newImageRect("Select.gif",ButtonWidth,ButtonHeight)
	rowTitle:setFillColor(0)
	rowTitle.x = 30
	rowTitle.y = rowHeight *0.5
end 

function OneMuscleWorkoutMenu()
	screen = 2
	print("Screen = "..screen)
	print('Which muscle')
	CreateMenuButton()

	WhichMuscleText = display.newText("Which muscle group?",display.contentWidth/2, display.contentHeight*1/10, font,25)

	local tableView = widget.newTableView(
    {
    	left 			= display.contentWidth/2 - display.actualContentWidth/2,
        top 			= display.actualContentHeight*2/10,
        height 			= display.actualContentHeight*8/10,
        width 			= display.actualContentWidth ,
        onRowRender 	= onRowRender,
        onRowTouch 		= onRowTouch,
        listener 		= scrollListener,
        hideBackground 	= true
    }
	)

	for i = 1 ,10 do
		tableView:insertRow{}
	end


end

function OneMuscleWorkoutGeneric()
	screen = 3
	print("Screen = "..screen)
	removeOneMuscleMenu()
	
	OneMuscleExercises 		= {}
	OneMuscleExercisesText 	= {}
	OneMuscleExercisesJPG	= {}

	for i=1,6 do
		OneMuscleExercises[i] 	 	= AllExercisesTable[OneMuscleGroup][i]
		OneMuscleExercisesText[i] 	= display.newText(OneMuscleExercises[i],display.contentWidth*((1 + 4*(math.floor((i-1)/2)))/10),display.contentHeight*(((i%2)*(-7))+10)/15, font,15) 
		OneMuscleExercisesText[i]:setFillColor( 0, 0, 0 )

		OneMuscleExercisesJPG[i]		= display.newImageRect("backgrounds/" .. OneMuscleExercisePath .. OneMuscleExercises[i] .. '.jpg', 125,90) 
		OneMuscleExercisesJPG[i].x 		= display.contentWidth*((1 + 4*(math.floor((i-1)/2)))/10)
		OneMuscleExercisesJPG[i].y 		= display.contentHeight*(((i%2)*(-7))+10)/15 + 55
	end

end

function BicepsWorkoutListener(event)
	OneMuscleGroup = 1 --
	OneMuscleExercisePath = "Bicep Exercises/"
	OneMuscleWorkoutGeneric()
end

function TricepsWorkoutListener(event)
	OneMuscleGroup = 2 --
	OneMuscleExercisePath = "Tricep Exercises/"
	OneMuscleWorkoutGeneric()
end

function ChestWorkoutListener(event)
	OneMuscleGroup = 3 --
	OneMuscleExercisePath = "Chest Exercises/"
	OneMuscleWorkoutGeneric()
end

function ShouldersWorkoutListener(event)
	OneMuscleGroup = 4 --
	OneMuscleExercisePath = "Shoulder Exercises/"
	OneMuscleWorkoutGeneric()
end

function BackWorkoutListener(event)
	OneMuscleGroup = 5 --
	OneMuscleExercisePath = "Back Exercises/"
	OneMuscleWorkoutGeneric()

end

function LegsWorkoutListener(event)
	OneMuscleGroup = 6 --
	OneMuscleExercisePath = "Leg Exercises/"
	OneMuscleWorkoutGeneric()
end

function TwoMuscleWorkoutMenu()
	screen = 2
	print("Screen = "..screen)
	print('Which muscles')
	CreateMenuButton()

	-- fill screen to determine width height
	local testing 	= display.newRect(display.contentWidth/2, display.contentHeight/2 ,10, 10)
	testing.width 	= display.contentWidth
	testing.height 	= display.contentHeight

	testing.width 	= display.actualContentWidth  - 10
	testing.height 	= display.actualContentHeight - 10
end



--All the button handlers
function OneMuscleButtonHandler( event )
	workout = 1
	removeMenu()
	print('One muscle selected')
	OneMuscleWorkoutMenu()
end

function TwoMuscleButtonHandler( event )
	workout = 2
	removeMenu()
	print('Two muscle selected')
	TwoMuscleWorkoutMenu()
end

function FullBodyButtonHandler( event )
	workout = 3
	removeMenu()
	print('FullBody selected')
	FullBodyWorkoutMenu()
end


function WriteToFile()
	-- Data (string) to write
 	print("Writing to file")
	-- Path for the file to write
	path = system.pathForFile( "weights.txt", system.DocumentsDirectory )
	-- Open the file handle
	file, errorString = io.open( path, "w" )
 
	if not file then
	    -- Error occurred; output the cause
	    print( "File error: " .. errorString )
	else
	    -- Write data to file
	    file:write( saveData )
	    -- Close the file handle
	    io.close( file )
	end
 
	file = nil
end


function ReadFile()
	path = system.pathForFile( "weights.txt", system.DocumentsDirectory )
	file, errorString = io.open( path, "r" )
	contents = file:read()
	print("Content: " .. contents)
	--contenttext = display.newText(contents,display.contentWidth/2, display.contentHeight/2, font,50)
end

--Listeners
function ExerciseTextBoxListener( event )
	ExerciseWeight = {}
	if ( event.phase == "ended" or event.phase == "submitted" ) then
		print(tostring(event.target.text))
		ExerciseWeight[1]  = tonumber(event.target.text) --converts a string to nil
		if ExerciseWeight[1] == nil then ExerciseWeight[1] = 1 end
	end

end



menu()







--------Not used yet-------------------
function ButtonHandler( event, Button )
	
	if (event.phase == "began") then  
		--press down and hold
		Button:removeSelf()
		Button:removeEventListener("touch", ButtonHandler)
		Button = nil

		Button = display.newImageRect("blank on.gif",120,35)
		Button:addEventListener("touch", ButtonHandler)

		Button.xScale = 0.95 -- scale the button on touch release 
		Button.yScale = 0.95
		Button.x = display.contentWidth/5
		Button.y = display.contentHeight*4/5

	elseif (event.phase == "moved" or event.phase == "ended" or event.phase == "cancelled") then
		Button:removeSelf()
		Button:removeEventListener("touch", ButtonHandler)
		
		Button = display.newImageRect("blank on.gif",120,35)
		Button:addEventListener("touch", ButtonHandler)
		Button.xScale = 1 
		Button.yScale = 1
		Button.x = display.contentWidth/5
		Button.y = display.contentHeight*4/5
 		print('Yeah')
	end
end 
