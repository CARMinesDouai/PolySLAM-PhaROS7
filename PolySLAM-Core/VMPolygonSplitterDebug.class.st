Class {
	#name : #VMPolygonSplitterDebug,
	#superclass : #VMPolygonSplitter,
	#category : #'PolySLAM-Core-Data Structures: Polygons'
}

{ #category : #'private - computing' }
VMPolygonSplitterDebug >> onLinePlacement: lineSeg [
	| cw deltaAngle |
	
	cw := originalPolygon isCW.
	deltaAngle := (plane deltaAngle: lineSeg) abs.
	
	((deltaAngle < Float halfPi) xor: [cw])
		ifTrue: [ Transcript show: '  online: left'; cr. ]
		ifFalse: [ Transcript show: '  online: right'; cr. ].
	
	^ super onLinePlacement: lineSeg.

]

{ #category : #'private - computing' }
VMPolygonSplitterDebug >> processLineSegment: aLineSeg index: index [
	plane fuzzyPoint: aLineSeg pointA
		ifOnLeftSideDo: [
			plane fuzzyPoint: aLineSeg pointB
				ifOnLeftSideDo: [ Transcript show: 'L-L, ', aLineSeg printString; cr. ]
				ifOnRightSideDo: [ Transcript show: 'L-R, ', aLineSeg printString; cr. ]
				ifOnLineDo: [ Transcript show: 'L-C, ', aLineSeg printString; cr. ] ]
		ifOnRightSideDo: [
			plane fuzzyPoint: aLineSeg pointB
				ifOnLeftSideDo: [ Transcript show: 'R-L', aLineSeg printString; cr. ]
				ifOnRightSideDo: [ Transcript show: 'R-R, ', aLineSeg printString; cr. ]
				ifOnLineDo: [ Transcript show: 'R-C, ', aLineSeg printString; cr. ] ]
		ifOnLineDo: [
			plane fuzzyPoint: aLineSeg pointB
				ifOnLeftSideDo: [ Transcript show: 'C-L, ', aLineSeg printString; cr. ]
				ifOnRightSideDo: [ Transcript show: 'C-R, ', aLineSeg printString; cr. ]
				ifOnLineDo: [ Transcript show: 'C-C, ', aLineSeg printString; cr. ] ].
	super processLineSegment: aLineSeg index: index.

]
