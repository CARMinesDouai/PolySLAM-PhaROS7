Class {
	#name : #PSLinkingLeaf,
	#superclass : #PSLinkingNode,
	#instVars : [
		'connectedRoots'
	],
	#category : #'PolySLAM-Pipeline-Algo'
}

{ #category : #accessing }
PSLinkingLeaf >> connectedRoots [
	^ connectedRoots
]

{ #category : #'instance creation' }
PSLinkingLeaf >> from: aValue with: nodes [
	nodeValue := aValue.
	connectedRoots := nodes.
	nodes isEmpty
		ifTrue:[
			connected := false]
		ifFalse:[
			connected := true].
	nodeValue visited: connected.
	^ self
]

{ #category : #testing }
PSLinkingLeaf >> isConnected [
	^ connected
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
PSLinkingLeaf >> isLeaf [
	^ true
]

{ #category : #querying }
PSLinkingLeaf >> leave [
	^ {self} asOrderedCollection 
]
