Class {
	#name : #VMOldPolygonRenderer,
	#superclass : #VMFigureRenderer,
	#instVars : [
		'solid',
		'fillColor'
	],
	#category : #'PolySLAM-Extra-GUI-Athens'
}

{ #category : #accessing }
VMOldPolygonRenderer >> fillColor [
	^ fillColor
]

{ #category : #accessing }
VMOldPolygonRenderer >> fillColor: anObject [
	fillColor := anObject
]

{ #category : #initialization }
VMOldPolygonRenderer >> initialize [
	super initialize.
	solid := true.
	fillColor := Color gray.
]

{ #category : #accessing }
VMOldPolygonRenderer >> labelPosition [
	^ self model vertices first
]

{ #category : #accessing }
VMOldPolygonRenderer >> length [
	^ self model vertices size
	
]

{ #category : #accessing }
VMOldPolygonRenderer >> points [ 
	^ self model vertices 
]

{ #category : #rendering }
VMOldPolygonRenderer >> renderOn: canvas [	
	
	self solid ifTrue: [
		|c path|
		c := self fillColor.
		self model cw ifTrue: [
			c := Color white ].
		canvas setPaint: c.
		
		path := canvas createPath: [ :builder |
			builder absolute.
			builder moveTo: self vertices first.
			1 to: (self length - 1) do: [ :i |
				builder lineTo: (self vertices at: i+1).
			].
			builder lineTo: self vertices first.
		].

		canvas drawShape: path.
	].

	1 to: (self length - 1) do: [ :i |
		self renderStyledLineFrom: (self model vertices at: i) to: (self model vertices at: (i+1) ) in: canvas
	].
	self renderStyledLineFrom: self model vertices last to: self model vertices first in: canvas	.
	
	super renderOn: canvas.

]

{ #category : #accessing }
VMOldPolygonRenderer >> solid [
	^ solid
]

{ #category : #accessing }
VMOldPolygonRenderer >> solid: anObject [
	solid := anObject
]

{ #category : #accessing }
VMOldPolygonRenderer >> vertices [
	^ self model vertices
]
