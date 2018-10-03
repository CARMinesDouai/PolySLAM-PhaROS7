Class {
	#name : #VMPolygonRenderer,
	#superclass : #VMBaseRenderer,
	#instVars : [
		'autoColor',
		'renderSectorBorder'
	],
	#category : #'PolySLAM-Extra-GUI-Athens'
}

{ #category : #accessing }
VMPolygonRenderer >> autoColor [
	autoColor := true.
]

{ #category : #accessing }
VMPolygonRenderer >> autoColor: aBoolean [
	autoColor := aBoolean.
]

{ #category : #accessing }
VMPolygonRenderer >> color: aColor [
	super color: aColor.
	autoColor := false.
]

{ #category : #initialization }
VMPolygonRenderer >> initialize [
	super initialize.
	renderSectorBorder := true.
	autoColor := true.
]

{ #category : #rendering }
VMPolygonRenderer >> renderFilledOn: aCanvas [
	
	model isCW ifTrue: [
		self renderFilledPolygonOn: aCanvas lineSegments: model color: Color veryLightGray.
	] ifFalse: [
		self renderFilledPolygonOn: aCanvas lineSegments: model color: Color white.
	]


]

{ #category : #rendering }
VMPolygonRenderer >> renderOn: aCanvas [

	self renderFilledOn: aCanvas.
	self renderOutlineOn: aCanvas.

	
]

{ #category : #rendering }
VMPolygonRenderer >> renderOutlineOn: aCanvas [

	autoColor ifTrue: [
		self model do: [ :lineSeg |
			"sectors are rendered as line segments, obstacles and frontiers as arrows"
			lineSeg type isSector
				ifTrue: [
					renderSectorBorder ifTrue: [
						self renderStyledLineSegFrom: lineSeg pointA to: lineSeg pointB on: aCanvas color: lineSeg type renderColor. ] ]
				ifFalse: [ self renderArrow: lineSeg on: aCanvas. ].
			
			"(lineSeg asRenderableElement)
				lineWidth: self lineWidth;
				renderOn: aCanvas."
		].
	] ifFalse: [
		self model do: [ :lineSeg |
			(lineSeg asRenderableElement)
				color: color;
				lineWidth: self lineWidth;
				renderOn: aCanvas.
		].
	].
	

]

{ #category : #accessing }
VMPolygonRenderer >> renderSectorBorder [
	^renderSectorBorder
]

{ #category : #accessing }
VMPolygonRenderer >> renderSectorBorder: aBoolean [
	renderSectorBorder := aBoolean
]
