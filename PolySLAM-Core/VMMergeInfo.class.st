Class {
	#name : #VMMergeInfo,
	#superclass : #Object,
	#instVars : [
		'alignmentScore',
		'lineSeg',
		'startDist',
		'startDeltaAngle',
		'startProjectionFactor',
		'endProjectionFactor',
		'startLineSeg',
		'endLineSeg'
	],
	#category : #'PolySLAM-Core-SLAM - Maps'
}

{ #category : #'as yet unclassified' }
VMMergeInfo class >> lineSeg: lineSegObj [
	^(self new)
		lineSeg: lineSegObj;
		yourself.
]

{ #category : #'as yet unclassified' }
VMMergeInfo class >> rendererClass [
	^VMMergeInfoRenderer.
]

{ #category : #accessing }
VMMergeInfo >> alignmentScore [
	^alignmentScore.
]

{ #category : #accessing }
VMMergeInfo >> alignmentScore: aNumber [
	alignmentScore := aNumber.
]

{ #category : #'as yet unclassified' }
VMMergeInfo >> asRenderableElement [
	^ self class rendererClass new model: self
]

{ #category : #computing }
VMMergeInfo >> computeScore [
	^( self computeScoreDist: startDist angle: startDeltaAngle ).
]

{ #category : #computing }
VMMergeInfo >> computeScoreDist: dist angle: angle [
	^( dist squared ) + ( angle squared * 5 ).
]

{ #category : #accessing }
VMMergeInfo >> endLineSeg [
	^endLineSeg.
]

{ #category : #accessing }
VMMergeInfo >> endLineSeg: aLineSeg [
	endLineSeg := aLineSeg.
]

{ #category : #accessing }
VMMergeInfo >> endProjectionFactor [
	^endProjectionFactor.
]

{ #category : #accessing }
VMMergeInfo >> endProjectionFactor: factor [
	endProjectionFactor := factor.
]

{ #category : #accessing }
VMMergeInfo >> lineSeg [
	^lineSeg.
]

{ #category : #accessing }
VMMergeInfo >> lineSeg: lineSegObj [
	lineSeg := lineSegObj.
]

{ #category : #printing }
VMMergeInfo >> printString [
	^'MergeInfo: ',
		' score=', (alignmentScore
			ifNil: [ 'nil' ]
			ifNotNil: [(alignmentScore printShowingDecimalPlaces: 4)] ),
		' angle=', (startDeltaAngle
			ifNil: [ 'nil' ]
			ifNotNil: [ (startDeltaAngle printShowingDecimalPlaces: 4) ]),
		' dist=', (startDist 
			ifNil: [ 'nil' ]
			ifNotNil: [(startDist printShowingDecimalPlaces: 4)]).
			
		
	
]

{ #category : #accessing }
VMMergeInfo >> startDeltaAngle [
	^startDeltaAngle.
]

{ #category : #accessing }
VMMergeInfo >> startDeltaAngle: angle [
	startDeltaAngle := angle.
]

{ #category : #accessing }
VMMergeInfo >> startDist [
	^startDist.
]

{ #category : #accessing }
VMMergeInfo >> startDist: dist [
	startDist := dist.
]

{ #category : #accessing }
VMMergeInfo >> startLineSeg [
	^startLineSeg.
]

{ #category : #accessing }
VMMergeInfo >> startLineSeg: aLineSeg [
	startLineSeg := aLineSeg.
]

{ #category : #accessing }
VMMergeInfo >> startProjectionFactor [
	^startProjectionFactor.
]

{ #category : #accessing }
VMMergeInfo >> startProjectionFactor: factor [
	startProjectionFactor := factor.
]
