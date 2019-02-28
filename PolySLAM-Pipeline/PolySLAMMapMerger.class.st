Class {
	#name : #PolySLAMMapMerger,
	#superclass : #Object,
	#instVars : [
		'map',
		'simplifierThreshold',
		'noiseThreshold'
	],
	#category : #'PolySLAM-Pipeline-Core'
}

{ #category : #accessing }
PolySLAMMapMerger >> addKeyframe: keyframe [
	|newmap simplifiedPolygon|
	"merge the keyframe to the map"
	simplifiedPolygon := (VMVectorCollectionSimplifier compute: keyframe polygon inlierThreshold: self simplifierThreshold) result.
	map isEmpty ifTrue: [ 
		map add: simplifiedPolygon asDoublyConnectedEdgeList.
		^self
	].
	newmap := OrderedCollection new.
	newmap := newmap, (self mergeOuterPolygon: map first with: simplifiedPolygon).
	map removeFirst.
	map do:[:chain|
		newmap := newmap, (self mergeInnerPolygon: chain with: simplifiedPolygon)
	].
	Transcript show: 'Processed ', (keyframe id asString); cr.
	map := newmap 
]

{ #category : #accessing }
PolySLAMMapMerger >> clear [
	map := OrderedCollection new.
]

{ #category : #initialization }
PolySLAMMapMerger >> initialize [
	map := OrderedCollection new.
	simplifierThreshold := 0.001. "1 mm"
	noiseThreshold := 0.01 "1cm"
]

{ #category : #accessing }
PolySLAMMapMerger >> map [
	^ map
]

{ #category : #accessing }
PolySLAMMapMerger >> mergeInnerPolygon: aChain with: aPolygon [
		| result|
		result := aChain mergeWith: aPolygon.
		result ifEmpty: [ result add: aChain ].
		^ result select:[:chain|
				(chain isPolygon) &
				(((chain isCCW) & (chain isFrontier)) not) &
				(((chain  isFrontier) & (chain area abs < self noiseThreshold )) not) ]
]

{ #category : #accessing }
PolySLAMMapMerger >> mergeOuterPolygon: aChain with: aPolygon [
	| result|
	result := aChain mergeWith: aPolygon.
	^result select:[:chain|
				(chain isPolygon) &
				(((chain isCCW) & (chain isFrontier)) not) &
				(((chain  isFrontier) & (chain area abs < self noiseThreshold )) not) ]
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
	map := map collect:[:chain|
		(VMVectorCollectionSimplifier compute: chain asVMPolygon inlierThreshold: self simplifierThreshold) result asDoublyConnectedEdgeList ].
]
