Class {
	#name : #VMBSPMapPlotter,
	#superclass : #VMBSPTreePlotter,
	#instVars : [
		'poseCollection'
	],
	#category : #'PolySLAM-Extra-Gnuplot plotter'
}

{ #category : #accessing }
VMBSPMapPlotter >> initialize [
	super initialize.
	poseCollection := nil.
]

{ #category : #plotting }
VMBSPMapPlotter >> plotOn: aSubProcess [

	super plotOn: aSubProcess.
	
	poseCollection ifNotNil: [
		self plotPoseCollection: poseCollection color: Color orange.
	].
]

{ #category : #accessing }
VMBSPMapPlotter >> poseCollection [
	^ poseCollection
]

{ #category : #accessing }
VMBSPMapPlotter >> poseCollection: aCollection [
	poseCollection := aCollection.
]
