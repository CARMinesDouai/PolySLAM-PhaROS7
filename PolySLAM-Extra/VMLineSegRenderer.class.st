"
This class renders a single line segment in the viewer.

The model should be a VMLine (or derived class) instance. The model will always be rendered as a line segment, even if the model is a line or a ray.
"
Class {
	#name : #VMLineSegRenderer,
	#superclass : #VMBaseRenderer,
	#category : #'PolySLAM-Extra-GUI-Athens'
}

{ #category : #'as yet unclassified' }
VMLineSegRenderer >> initialize [
	super initialize.
	
	color := nil.
]

{ #category : #rendering }
VMLineSegRenderer >> renderOn: aCanvas [
	| line |
	line := self model.
	
	color
		ifNil: [ self renderArrow: line on: aCanvas ]
		ifNotNil: [ self renderStyledLineSegFrom: line pointA to: line pointB on: aCanvas color: color. ].
	

]
