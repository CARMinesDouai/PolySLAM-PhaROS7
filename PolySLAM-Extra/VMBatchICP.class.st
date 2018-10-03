Class {
	#name : #VMBatchICP,
	#superclass : #Object,
	#instVars : [
		'icp',
		'icpTF',
		'nnc',
		'inputCollection',
		'tfHistory',
		'polygonHistory'
	],
	#category : #'PolySLAM-Extra-Playgrounds'
}

{ #category : #initialization }
VMBatchICP >> initialize [
	tfHistory := OrderedCollection new.
	polygonHistory := OrderedCollection new.
	
	icp := VMVectorICP new.
	icpTF := VMTFMatrix identity.
]

{ #category : #accessing }
VMBatchICP >> input: aCollectionOfPolygons [
	inputCollection := aCollectionOfPolygons.
]

{ #category : #loop }
VMBatchICP >> iterateOnce: polygon [
	| startPolygon resultPolygon |
	
	startPolygon := polygon transform: icpTF.
	icp
		compute: (startPolygon asPointCollection removeLast; yourself)
		with: nnc.
	
	icpTF := icp finalTF * icpTF.
	resultPolygon := (VMVectorCollectionSimplifier compute: (startPolygon transform: icpTF)) result.
	tfHistory add: icpTF.
	polygonHistory add: resultPolygon.
	
	self updateNNC: resultPolygon.

]

{ #category : #loop }
VMBatchICP >> loop [
	"initialize nnc if not already set"
	nnc ifNil: [ nnc := VMLinearNNSVectorCollection new. ].
	nnc ifEmpty: [
		nnc addAll: (
			inputCollection first
				select: [ :vec | vec isObstacle ] as: VMLinearNNSVectorCollection) ].
	
	inputCollection do: [ :polygon |
		self iterateOnce: polygon.
	].
]

{ #category : #accessing }
VMBatchICP >> nnc [
	^ nnc
]

{ #category : #accessing }
VMBatchICP >> nnc: aNNCollection [
	nnc := aNNCollection.
]

{ #category : #accessing }
VMBatchICP >> polygonHistory [
	^ polygonHistory
]

{ #category : #accessing }
VMBatchICP >> tfHistory [
	^ tfHistory
]

{ #category : #loop }
VMBatchICP >> updateNNC: resultPolygon [
	nnc addAll: (resultPolygon select: [ :vec | vec isObstacle ] as: VMLinearNNSVectorCollection).
]
