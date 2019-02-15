Class {
	#name : #VMFittingCollectionRenderer,
	#superclass : #VMBaseRenderer,
	#instVars : [
		'showLabels'
	],
	#category : #'PolySLAM-Extra-GUI-Athens'
}

{ #category : #accessing }
VMFittingCollectionRenderer >> bounds [
	| rect |
	
	rect := model first bounds.
	model allButFirstDo: [ : result | rect merge: result line bounds].
	
	^ rect
]

{ #category : #initialization }
VMFittingCollectionRenderer >> initialize [
	super initialize.
	lineWidth := lineWidth / 8.
	showLabels := true.
]

{ #category : #rendering }
VMFittingCollectionRenderer >> renderOn: aCanvas [
	textScale := 0.004.
	model doWithIndex: [ :result :index |
		| pointA pointB |
		pointA := result vectorCollection first pointA.
		pointB := result vectorCollection last pointB.
		self renderStyledLineSegFrom: pointA
			to: pointB
			on: aCanvas
			color: (Color byInteger: index).
		showLabels ifTrue: [
			self renderString: index printString at: (pointA + pointB) * 0.5 in: aCanvas color: Color yellow]. ].
	
	model doWithIndex: [ :result :index |
		| points |
		points := result vectorCollection collect: [ :v | v pointA ].
		(VMPointCollectionRenderer new model: points) lineWidth: lineWidth * 8 / 20; color: (Color byInteger: index); renderOn: aCanvas. ].


]
