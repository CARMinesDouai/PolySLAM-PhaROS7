Class {
	#name : #VMTrajectoryRenderer,
	#superclass : #VMFigureRenderer,
	#category : #'PolySLAM-Extra-GUI-Athens'
}

{ #category : #'as yet unclassified' }
VMTrajectoryRenderer >> renderOn: canvas [
	self model collection doWithIndex: [ :location :i |
		(i > 1) ifTrue: [
			"todo: draw arrow from i-1 to i"
		].
		location asRenderableElement renderOn: canvas.
	].
]
