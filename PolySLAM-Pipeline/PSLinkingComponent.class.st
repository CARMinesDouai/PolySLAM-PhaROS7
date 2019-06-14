Class {
	#name : #PSLinkingComponent,
	#superclass : #Object,
	#instVars : [
		'indices',
		'chain'
	],
	#category : #'PolySLAM-Pipeline-Algo'
}

{ #category : #accessing }
PSLinkingComponent >> chain [
	^ chain
]

{ #category : #accessing }
PSLinkingComponent >> chain: anObject [
	chain := anObject
]

{ #category : #accessing }
PSLinkingComponent >> indices [
	^ indices
]

{ #category : #accessing }
PSLinkingComponent >> indices: anObject [
	indices := anObject
]

{ #category : #initialization }
PSLinkingComponent >> initialize [
	super initialize.
	indices := Set new.
	chain := VMPolygon new.
]
