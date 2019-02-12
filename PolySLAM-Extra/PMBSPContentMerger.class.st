Class {
	#name : #PMBSPContentMerger,
	#superclass : #Object,
	#category : #'PolySLAM-Extra-Experimental'
}

{ #category : #actions }
PMBSPContentMerger class >> merge: aCollection [
	^ self new
		merge: aCollection
]

{ #category : #'merging - helper' }
PMBSPContentMerger >> collectVectorsHyperplane: hyperplane vectorCollection: vectors [
	| pairCollection |

	pairCollection := OrderedCollection new.
	vectors do: [ :rightPolygon |
		rightPolygon select: [ :vec | vec type isSector ] thenDo: [ :rightVector |
			(hyperplane isCollinearWith: rightVector)
				ifTrue: [ pairCollection add: { rightVector. rightPolygon }. ]. ]. ].
	
	^ pairCollection
]

{ #category : #'merging - helper' }
PMBSPContentMerger >> findMatchesFor: aVector in: pairCollection [
	| matches |
	
	matches := pairCollection select: [ :pair | (pair first pointA = aVector pointB) and: [pair first pointB = aVector pointA] ].
	
	^ matches

]

{ #category : #merging }
PMBSPContentMerger >> merge: root [
	| left right |
	
	root isLeaf
		ifTrue: [
			^ root sector
				ifNil: [ ^ {} ]
				ifNotNil: [ ^ { root sector } ]. ].
		
	left := self merge: root leftChild.
	right := self merge: root rightChild.
	
	^ self mergeLeft: left withRight: right onPlane: root hyperplane
	
]

{ #category : #'merging - helper' }
PMBSPContentMerger >> mergeLeft: left withRight: right onPlane: hyperplane [
	| pairCollection rightCopy leftCopy |
	rightCopy := OrderedCollection new addAll: right; yourself.
	leftCopy := left collect: [ :p | p copy ].
	
	pairCollection := self collectVectorsHyperplane: hyperplane vectorCollection: rightCopy.
	
	leftCopy do: [ :leftPolygon |
		(leftPolygon select: [ :vec | vec type isSector ]) do: [ :leftVector |
			(hyperplane isCollinearWith: leftVector) ifTrue: [
				| matches |
				matches := self findMatchesFor: leftVector in: pairCollection.
				((matches size = 1) and: [rightCopy includes: matches first second]) ifTrue: [
					| pair vectors offset |
					pair := matches first.
					vectors := OrderedCollection new.
					offset := pair second indexOf: pair first.
					1 to: pair second size - 1 do: [ :index |
						vectors add: (pair second atWrap: index + offset). ].
					leftPolygon replaceVector: leftVector withCollection: vectors.
					rightCopy remove: pair second. ]. ]. ]. ].
	
	^ VMPolygonCollection new
		addAll: leftCopy;
		addAll: rightCopy;
		yourself

]
