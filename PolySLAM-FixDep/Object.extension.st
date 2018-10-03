Extension { #name : #Object }

{ #category : #'*PolySLAM-FixDep' }
Object >> ifNil: aBlock  ifNotNilDo: anotherBlock [
	^self ifNil: aBlock  ifNotNil: anotherBlock  
]

{ #category : #'*PolySLAM-FixDep' }
Object >> ifNotNilDo: ablock [
	^ self ifNotNil: ablock
]
