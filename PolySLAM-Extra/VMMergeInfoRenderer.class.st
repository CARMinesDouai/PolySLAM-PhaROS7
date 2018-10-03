Class {
	#name : #VMMergeInfoRenderer,
	#superclass : #VMFigureRenderer,
	#category : #'PolySLAM-Extra-GUI-Athens'
}

{ #category : #'as yet unclassified' }
VMMergeInfoRenderer >> initialize [
	super initialize.
	
	self lineWidth: 0.1.
]

{ #category : #'as yet unclassified' }
VMMergeInfoRenderer >> points [
	| newPoint |
	newPoint := model lineSeg pointA + (model lineSeg pointB) * 0.5.
	^{ newPoint }.
]

{ #category : #'as yet unclassified' }
VMMergeInfoRenderer >> renderOn: aCanvas [
	| lineSeg |
	
	lineSeg := model lineSeg.
	
	self renderStyledLineFrom: (lineSeg pointA) to: (lineSeg pointB) in: aCanvas.

]

{ #category : #'as yet unclassified' }
VMMergeInfoRenderer >> renderOn: aCanvas tf: frame [
	| lineSeg from to |
	
	lineSeg := model lineSeg.
	"1 haltOnce."
	from := (lineSeg pointA rotateBy: frame orientation about: (0@0)) + frame position.
	to  := (lineSeg pointB rotateBy: frame orientation about: (0@0)) + frame position.

	self setColor.
	self renderStyledLineFrom: from to: to in: aCanvas.

]

{ #category : #'as yet unclassified' }
VMMergeInfoRenderer >> setColor [
	| score |
	
	score := model alignmentScore.
	
	(score > 10.0 ) ifTrue: [
		self color: Color red.
		^self.
	].

	(score < 0.5) ifTrue: [
		self color: Color green.
		^self.
	].

	self color: (
		Color
			h: (score - 0.5 / 9.5 * 180)
			s: 1.0
			v: 1.0
	).
]
