Class {
	#name : #VMScanDataRenderer,
	#superclass : #VMFigureRenderer,
	#instVars : [
		'visGraphRenderer'
	],
	#category : #'PolySLAM-Extra-GUI-Athens'
}

{ #category : #'as yet unclassified' }
VMScanDataRenderer >> points [
	^model collection.
]

{ #category : #'as yet unclassified' }
VMScanDataRenderer >> renderOn: canvas frame: referenceFrame [
	| frame radius path stroke |
	
	"Transcript
		show: 'ScanDataRenderer model frame: ', (model tf printString), ', ref frame: ', referenceFrame printString;
		cr.
	"
	frame := referenceFrame multiplyLeft: (model tf).
	radius := 0.015.
	
	path := canvas createPath: [ :builder |
		builder absolute.
		
		model collection do: [ :point |
			| newPoint |
			newPoint := point rotateBy: frame orientation about: 0@0.
			newPoint := newPoint + frame position.
			
			builder
				moveTo: (newPoint + radius);
				cwArcTo: (newPoint - radius) angle: Float pi;
				cwArcTo: (newPoint + radius) angle: Float pi.
		].
	].
	
	stroke := canvas setStrokePaint: self color.
	stroke width: self lineWidth.
	canvas drawShape: path.
	
	super renderOn: canvas
]
