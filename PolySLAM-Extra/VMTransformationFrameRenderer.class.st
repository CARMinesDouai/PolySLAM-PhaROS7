Class {
	#name : #VMTransformationFrameRenderer,
	#superclass : #VMFigureRenderer,
	#category : #'PolySLAM-Extra-GUI-Athens'
}

{ #category : #'as yet unclassified' }
VMTransformationFrameRenderer >> renderOn: canvas [
	"draws a 2d coordinate frame (red=x-axis, blue=z-axis) at the position provided by 'model frame'."
	| frame point theta vector |
	
	frame := model frame.
	point := frame position.
	theta := frame orientation.
	
	self color: Color red.
	vector := (10*lineWidth)@0 rotateBy: theta about: 0@0.
	self renderStyledLineFrom: point to: (point + vector) in: canvas.
	
	self color: Color blue.
	vector := 0@(10*lineWidth) rotateBy: theta about: 0@0.
	self renderStyledLineFrom: point to: (point + vector) in: canvas.
	

]
