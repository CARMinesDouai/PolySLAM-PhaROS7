Class {
	#name : #PSLinkingLeaf,
	#superclass : #PSLinkingJoin,
	#instVars : [
		'connectedRoots'
	],
	#category : #'PolySLAM-Pipeline-Algo'
}

{ #category : #querying }
PSLinkingLeaf >> allChains [
	^ {  } asOrderedCollection
]

{ #category : #'as yet unclassified' }
PSLinkingLeaf >> connectedRootIds [
	^ connectedRoots 
]

{ #category : #'instance creation' }
PSLinkingLeaf >> from: aValue with: list [
	|node|
	joins := OrderedCollection new.
	connectedRoots := list.
	nodeValue := aValue.
	connectedRoots do:[:id|
		node := self lookUp: id.
		node ifNotNil: [joins add: node] ifNil: [self halt].
	].
	joins isEmpty
		ifTrue:[
			connected := false]
		ifFalse:[
			connected := true].
	nodeValue visited: connected.
	^ self
]

{ #category : #testing }
PSLinkingLeaf >> isConnectedTo: aCollectionOfEdges [
	|aCollection|
	aCollection := aCollectionOfEdges collect:[:e| e id].
	aCollection do:[:e|
		(connectedRoots includes:e)
			ifTrue:[^true]	
	].
	^ false
]

{ #category : #testing }
PSLinkingLeaf >> isJoin [
	^ false
]

{ #category : #testing }
PSLinkingLeaf >> isLeaf [
	^ true
]
