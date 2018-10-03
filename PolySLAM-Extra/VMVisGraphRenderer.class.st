Class {
	#name : #VMVisGraphRenderer,
	#superclass : #VMFigureRenderer,
	#category : #'PolySLAM-Extra-GUI-Athens'
}

{ #category : #initialization }
VMVisGraphRenderer >> initialize [
	super initialize.
	showVertices := true.
	showArrowHead := false
]

{ #category : #accessing }
VMVisGraphRenderer >> points [
	^ self model vertices
]

{ #category : #rendering }
VMVisGraphRenderer >> renderOn: canvas [
	super renderOn: canvas.
				
	self model vertices do: [ :v |
		v neighbors do: [ :neighbor |			
			self renderStyledLineFrom: v to: neighbor in: canvas
		]
	]
				
]
