VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
END
Attribute VB_Name = "Maybe"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = True
Option Explicit
'
' Maybe Class
' ===========
'
'
' Copywrite (C) 2014 Philip Wales
' This file (Maybe.cls) is distributed under the GPL-3.0 license
' Obtain a copy of the GPL-3.0 license <http://opensource.org/licenses/GPL-3.0>
'
' An object that optionally contains an item.  It's use is an abstraction from
' checking if a method returned a value or not.
'
'
Implements Equatable
Implements Showable
Implements Monadic
'
' Private Members
' ---------------
'
Private pVar As Variant
'
' Constructor
' -----------
'
Public Function Some(ByVal x) As Maybe
    
    Dim result As New Maybe
    result.Inject x
    Set Some = result
    
End Function
Public Function None() As Maybe

    Dim result As New Maybe
    Set None = result

End Function
Public Function MakeIf(ByVal pred As Boolean, ByVal x) As Maybe

    If pred Then
        Set MakeIf = Some(x)
    Else
        Set MakeIf = None
    End If
    
End Function
Public Function Attempt(ByVal delay As Delayed) As Maybe

    Dim result As Maybe
    On Error GoTo Fail
    Set result = Some(delay.Evaluate())
    On Error GoTo 0

CleanExit:
    Set Attempt = result

Exit Function

Fail:
    Set result = None()
    Resume CleanExit

End Function
'
' ### Friend Methods
'
Friend Sub Inject(ByVal x)

    Assign pVar, x

End Sub
'
' Public Methods
' --------------
'
Public Function IsNone() As Boolean
    
    IsNone = IsEmpty(pVar)
    
End Function
Public Function IsSome() As Boolean

    IsSome = (Not IsNone)

End Function
Public Property Get GetItem() As Variant
Attribute GetItem.VB_UserMemId = 0

    If IsSome Then
        Assign GetItem, pVar
    Else
        ValueError Me, "GetItem", "Cannot get None"
    End If
    
End Property
Public Function GetOrElse(ByVal other) As Variant

    If IsSome Then
        Assign GetOrElse, pVar
    Else
        Assign GetOrElse, other
    End If

End Function
'
' Equatable
' ----------
'
Public Function Equals(ByVal x) As Boolean

    Equals = False
    
    If TypeName(x) <> TypeName(Me) Then
        Exit Function
    End If
    
    Dim mx As Maybe
    Set mx = x
    
    If IsSome And mx.IsSome Then
        Equals = (defEquals.Equals(pVar, mx.GetItem))
    Else
        Equals = (IsNone And mx.IsNone)
    End If

End Function
Private Function Equatable_Equals(ByVal x) As Boolean

    Equatable_Equals = Equals(x)

End Function
'
' Monadic
' --------
'
Public Function Bind(ByVal op As Applicable) As Maybe

    Dim result As Maybe
    If IsSome Then
    
        On Error GoTo ErrHandler
        Dim opResult
        Assign opResult, op.Apply(pVar)
        Set result = opResult
        On Error GoTo 0
        
    Else
        Set result = None
    End If
    
    Set Bind = result
Exit Function
ErrHandler:
    Dim msg As String
    Select Case Err.Number
        Case vbErrorNums.TYPE_ERROR, vbErrorNums.OBJECT_REQUIRED
            msg = defShow.Show(op) & " did not return a Maybe object"
            Exceptions.TypeError Me, "Bind", msg
        Case Else
            Exceptions.BubbleError Me, "Bind", Err
    End Select
End Function
Public Function Map(ByVal op As Applicable) As Maybe

    Dim result As Maybe
    If IsSome Then
        Set result = Some(op.Apply(pVar))
    Else
        Set result = None
    End If
    Set Map = result
    
End Function
Private Function Monadic_Bind(ByVal op As Applicable) As Monadic

    Set Monadic_Bind = Bind(op)

End Function
Private Function Monadic_Map(ByVal op As Applicable) As Monadic

    Set Monadic_Map = Map(op)

End Function
Private Function Monadic_Unit(ByVal x) As Monadic

    Set Monadic_Unit = Some(x)

End Function
'
' Showable
' ---------
'
Public Function Show() As String

    Dim result As String
    If IsNone Then
        result = ParamShowableObject(Me)
    Else
        result = ParamShowableObject(Me, pVar)
    End If

    Show = result
    
End Function
Private Function Showable_Show() As String

    Showable_Show = Show

End Function
