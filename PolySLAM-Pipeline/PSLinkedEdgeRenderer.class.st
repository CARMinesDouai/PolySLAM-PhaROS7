Class {
	#name : #PSLinkedEdgeRenderer,
	#superclass : #VMBaseRenderer,
	#category : #'PolySLAM-Pipeline-Algo'
}

{ #category : #initialization }
PSLinkedEdgeRenderer >> initialize [
	super initialize.
	
	color := nil.
]

{ #category : #rendering }
PSLinkedEdgeRenderer >> renderOn: aCanvas [
	| line |
	line := self model value.
	
	color
		ifNil: [ self renderArrow: line on: aCanvas ]
		ifNotNil: [ self renderStyledLineSegFrom: line pointA to: line pointB on: aCanvas color: color. ].
	self model id ifNotNil: [ 
		"draw line id"
		font := LogicalFont familyName: 'Arial' pointSize: 10.
		aCanvas setFont: font.
		self renderString: self model id asString at: (((line pointA) +(line pointB)) / 2 ) in: aCanvas	 color: Color red
	]
]
