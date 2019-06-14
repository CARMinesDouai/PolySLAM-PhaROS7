Class {
	#name : #PolySLAMMapMerger,
	#superclass : #Object,
	#instVars : [
		'helper',
		'simplifierThreshold',
		'noiseThreshold'
	],
	#category : #'PolySLAM-Pipeline-Core'
}

{ #category : #accessing }
PolySLAMMapMerger >> addKeyframe: keyframe [
	| simplifiedPolygon|
	"merge the keyframe to the map"
	"simplifiedPolygon := (VMVectorCollectionSimplifier compute: keyframe polygon inlierThreshold: self simplifierThreshold) result."
	simplifiedPolygon := keyframe polygon.
	helper consume: simplifiedPolygon.
	"self simplifyMap "
	"(keyframe id % 10) = 0 ifTrue:[self simplifyMap ]."
]

{ #category : #accessing }
PolySLAMMapMerger >> clear [
	helper := PSMapMerger new.
]

{ #category : #initialization }
PolySLAMMapMerger >> initialize [
	helper := PSMapMerger new.
	simplifierThreshold := 0.001. "1 mm"
	noiseThreshold := 0.01 "1cm"
]

{ #category : #accessing }
PolySLAMMapMerger >> map [
	^ helper chains 
]

{ #category : #accessing }
PolySLAMMapMerger >> noiseThreshold [
	^ noiseThreshold
]

{ #category : #accessing }
PolySLAMMapMerger >> noiseThreshold: anObject [
	noiseThreshold := anObject
]

{ #category : #accessing }
PolySLAMMapMerger >> simplifierThreshold [
	^ simplifierThreshold
]

{ #category : #accessing }
PolySLAMMapMerger >> simplifierThreshold: anObject [
	simplifierThreshold := anObject
]

{ #category : #'as yet unclassified' }
PolySLAMMapMerger >> simplifyMap [
	self map collect:[:chain|
		(VMVectorCollectionSimplifier 
			compute: chain 
			inlierThreshold: self simplifierThreshold)
			result asDoublyConnectedEdgeList ]
		thenSelect:[:chain| chain size > 2].
		
	
]
