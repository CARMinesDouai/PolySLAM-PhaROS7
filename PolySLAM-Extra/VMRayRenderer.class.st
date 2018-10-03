"
This class renders a single ray in the viewer.

The model should be a VMLine (or derived class) instance. The model will always be rendered as a ray, even if the model is a line or a line segment.
"
Class {
	#name : #VMRayRenderer,
	#superclass : #VMBaseRenderer,
	#category : #'PolySLAM-Extra-GUI-Athens'
}

{ #category : #rendering }
VMRayRenderer >> renderOn: aCanvas viewer: viewer [
	| line |
	line := self model.
	
	self renderStyledRayFrom: line pointA to: line pointB on: aCanvas color: color.

]
