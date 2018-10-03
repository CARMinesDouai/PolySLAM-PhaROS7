Class {
	#name : #VMPathSearchTests,
	#superclass : #VMTests,
	#category : #'PolySLAM-Tests'
}

{ #category : #tests }
VMPathSearchTests >> testSearch [
	| visGraph points isolated |
	
	visGraph := VMVisGraph fromMap:(VMMapFactory fromData: VMDataSet dataMap_5).
	points := { 0@ -2. 5@3. }.
	isolated := OrderedCollection new.
	
	points do: [ :p |
		isolated add: ( VMIsolatedPoint fromPoint: p ).
	].
	
	(isolated at: 1) vertices first id: 'S'.	"start vertex"
	(isolated at: 2) vertices first id: 'G'.	"goal vertex"
	
	isolated do: [ :i |
		visGraph addPolygon: i.
	].
	
	VMPathSearch compute: visGraph from: ((isolated at: 1) vertex) to: ((isolated at: 2) vertex).
	
	
	

]

{ #category : #tests }
VMPathSearchTests >> testSearch2 [
	| visGraph points isolated |
	
	visGraph := VMVisGraph fromMap:(VMMapFactory fromData: VMDataSet dataMap_6).
	points := { -3 @ -8.  3 @ -8. }.
	isolated := OrderedCollection new.
	
	points do: [ :p |
		isolated add: ( VMIsolatedPoint fromPoint: p ).
	].
	
	(isolated at: 1) vertices first id: 'S'.	"start vertex"
	(isolated at: 2) vertices first id: 'G'.	"goal vertex"
	
	isolated do: [ :i |
		visGraph addPolygon: i.
	].
	
	VMPathSearch compute: visGraph from: ((isolated at: 1) vertex) to: ((isolated at: 2) vertex).
	
	
	

]
