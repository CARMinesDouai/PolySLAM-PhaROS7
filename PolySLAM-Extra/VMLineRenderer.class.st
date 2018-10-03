"
This class renders a single line (not line segment) in the viewer.

The model should be a VMLine (or derived class) instance. The model will always be rendered as a line, even if it is a line segment or a ray.
"
Class {
	#name : #VMLineRenderer,
	#superclass : #VMBaseRenderer,
	#category : #'PolySLAM-Extra-GUI-Athens'
}

{ #category : #rendering }
VMLineRenderer >> renderOn: aCanvas [
	| line |
	line := self model.
	
	self renderStyledLineFrom: line pointA to: line pointB on: aCanvas color: color.

]

{ #category : #rendering }
VMLineRenderer >> renderOn: aCanvas viewer: viewer [
	| line |
	line := self model.
	
	self renderStyledLineFrom: line pointA to: line pointB on: aCanvas color: color.

]
