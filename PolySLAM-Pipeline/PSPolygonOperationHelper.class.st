Class {
	#name : #PSPolygonOperationHelper,
	#superclass : #Object,
	#instVars : [
		'polygonA',
		'polygonB'
	],
	#category : #'PolySLAM-Pipeline-Algo'
}

{ #category : #'instance creation' }
PSPolygonOperationHelper class >> from: pA and: pB [
	^ self new
		polygonA: pA; 
		polygonB: pB;
		yourself
]

{ #category : #public }
PSPolygonOperationHelper >> perform [
	^ self subclassResponsibility 
]

{ #category : #accessing }
PSPolygonOperationHelper >> polygonA [
	^ polygonA
]

{ #category : #accessing }
PSPolygonOperationHelper >> polygonA: anObject [
	polygonA := anObject asDoublyConnectedEdgeList.
	polygonA close.
]

{ #category : #accessing }
PSPolygonOperationHelper >> polygonB [
	^ polygonB
]

{ #category : #accessing }
PSPolygonOperationHelper >> polygonB: anObject [
	polygonB := anObject asDoublyConnectedEdgeList.
	polygonB close
]
