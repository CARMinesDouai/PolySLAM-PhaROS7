Extension { #name : #Integer }

{ #category : #'*PolySLAM-Core' }
Integer >> as32ByteArray [
	| stream |
	
	stream := ByteArray new writeStream.
	stream nextPut: (self bitShift: -24) & 255.
	stream nextPut: (self bitShift: -16) & 255.
	stream nextPut: (self bitShift: -8) & 255.
	stream nextPut: self & 255.
	
	^stream contents

]

{ #category : #'*PolySLAM-Core' }
Integer >> asLineSegmentType [
	| types |
	types := #( VMLineType "0"
		VMLineTypeObstacle "1"
		VMLineTypeFrontier "2"
		VMLineTypeSector "3" ).
	
	(self between: 0 and: (types size) - 1) ifTrue: [
		^ (types at: self+1 ) asClass new.
		].
	
	self error: 'unsupported line segment type: ', self printString.
	
	^self.

]

{ #category : #'*PolySLAM-Core' }
Integer >> asVMPointType [
	| types |
	types := #( VMPointType "0"
		VMPointTypeObstacle "1"
		VMPointTypeFrontier "2"
		VMPointTypeOther "3"
		VMPointTypeIntersection "4").
	
	(self between: 0 and: (types size) - 1) ifTrue: [
		^ (types at: self+1 ) asClass new.
		].
	
	self error: 'unsupported point type: ', self printString.
	
	^self.

]
