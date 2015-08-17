{***********************************************************************************************************************
 *
 * TERRA Game Engine
 * ==========================================
 *
 * Copyright (C) 2003, 2014 by S�rgio Flores (relfos@gmail.com)
 *
 ***********************************************************************************************************************
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with
 * the License. You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on
 * an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations under the License.
 *
 **********************************************************************************************************************
 * TERRA_UI
 * Implements the UI class
 ***********************************************************************************************************************
}
Unit TERRA_UIView;
{$I terra.inc}

Interface
Uses {$IFDEF USEDEBUGUNIT}TERRA_Debug,{$ENDIF}
  TERRA_Object, TERRA_String, TERRA_Font, TERRA_Collections, TERRA_Image, TERRA_Utils, TERRA_TextureAtlas, TERRA_Application,
  TERRA_Vector3D, TERRA_Vector2D, TERRA_Matrix3x3, TERRA_Color, TERRA_Texture, TERRA_Math, TERRA_Tween,
  TERRA_Sprite, TERRA_Vector4D, TERRA_GraphicsManager, TERRA_FontRenderer, TERRA_UITransition, TERRA_Viewport, TERRA_Camera,
  TERRA_UIDimension, TERRA_UIWidget, TERRA_ClipRect, TERRA_EnumProperty, TERRA_DataSource, TERRA_Hashmap;

Const

  TextureAtlasWidth = 1024;
  TextureAtlasHeight = 512;

Type
  UIView = Class;

  UIView = Class(UIWidget)
    Protected
      _VirtualKeyboard:UIWidget;

		  _Focus:UIWidget;
      _Dragger:UIWidget;
      _Modal:UIWidget;
      _Highlight:UIWidget;
      _Draw:Boolean;

      _Transition:UITransition;

      _DefaultFont:TERRAFont;
      _Language:TERRAString;

      (*_WndCallback1:WidgetEventHandler;
      _WndCallback2:WidgetEventHandler;
      _PrevHighlight:UIWidget;*)

      _LastOver:UIWidget;
      _LastWidget:UIWidget;

      _HoldWidget:UIWidget;

      Procedure SetColorTable(const Value:TERRATexture);
      Procedure SetDefaultFont(const Value:TERRAFont);
      Procedure SetDragger(const Value:UIWidget);

      Function GetHighlight:UIWidget;

      Function GetFontRenderer():TERRAFontRenderer;

      Function GetModal():UIWidget;

      Procedure Clear;

    Public
      CloseButton:UIWidget;

      Key_Up:Integer;
      Key_Down:Integer;
      Key_Right:Integer;
      Key_Left:Integer;
      Key_Action:Integer;
      Key_Cancel:Integer;

(*      System_Wnd:UIWidget;
      System_Text:UIWidget;
      System_Btn:Array[0..2] Of UIWidget;
      System_BG:UIWidget;*)

      Constructor Create;
      Procedure Release; Override;

      Function GetObjectType:TERRAString; Override; 

      //Function SelectNearestWidget(Target:UIWidget):UIWidget;
      //Procedure GetFirstHighLight(GroupID:Integer);

      Function PickWidget(X,Y:Integer; WithEventsOnly:Boolean; Ignore:UIWidget = Nil):UIWidget;

		  Function OnKeyDown(Key:Word):UIWidget;
		  Function OnKeyUp(Key:Word):UIWidget;
		  Function OnKeyPress(Key:TERRAChar):UIWidget;

		  Function OnMouseDown(X,Y:Integer;Button:Word):UIWidget;
		  Function OnMouseUp(X,Y:Integer;Button:Word):UIWidget;
		  Function OnMouseWheel(X,Y:Integer; Delta:Integer):UIWidget;
		  Function OnMouseMove(X,Y:Integer):UIWidget;

      Procedure Render(View:TERRAViewport); Override;

      Procedure AfterEffects;

      Procedure SetFocus(Value:UIWidget);
      Procedure SetTransition(MyTransition:UITransition);

      Function GetVirtualKeyboard():UIWidget;

      Function OnRegion(X, Y:Integer):Boolean;

      Property ColorTable:TERRATexture Read _ColorTable Write SetColorTable;
      Property Saturation:Single Read GetSaturation Write SetSaturation;

      Property Focus:UIWidget Read _Focus Write SetFocus;
      Property Dragger:UIWidget Read _Dragger Write SetDragger;

      Property Transition:UITransition Read _Transition Write SetTransition;

      Property VirtualKeyboard:UIWidget Read GetVirtualKeyboard;

      Property LastWidget:UIWidget Read _LastWidget;

      Property DefaultFont:TERRAFont Read _DefaultFont Write SetDefaultFont;
      Property Modal:UIWidget Read GetModal Write _Modal;
      Property Highlight:UIWidget Read GetHighlight;
    End;

  UIManager = Class(ApplicationComponent)
    Protected
      _Viewport:TERRAViewport;
      _Camera:TERRACamera;
      
      _TextureAtlas:TextureAtlas;
      _UpdateTextureAtlas:Boolean;

      _UIList:Array Of UIView;
      _UICount:Integer;

      _Ratio:Single;

      _FontRenderer:TERRAFontRenderer;

      _AlignEnums:EnumCollection;
      _DirectionEnums:EnumCollection;

      _Controllers:Array Of UIController;
      _ControllerCount:Integer;

      Procedure OnAppResize; Override;
      Procedure OnOrientationChange; Override;

      Procedure UpdateRatio();

      Function GetWidth:Integer;
      Function GetHeight:Integer;

      Function GetTextureAtlas:TextureAtlas;

      Function GetFontRenderer:TERRAFontRenderer;

      Procedure RenderUIs;

    Public
      Procedure Init; Override;
      Procedure Resume; Override;

      Procedure Release; Override;

      Class Function Instance:UIManager;

      Procedure AddUI(UI:UIView);
      Procedure RemoveUI(UI:UIView);

      Procedure TextureAtlasClear();

      Procedure Render;
      Procedure AfterEffects;

      Function CreateProperty(Owner:TERRAObject; Const KeyName, ObjectType:TERRAString):TERRAObject; Override;

      Procedure AddController(Controller:UIController);
      Function GetControllerByName(Const Name:TERRAString):UIController;

      Procedure SetFontRenderer(const Value:TERRAFontRenderer);

      Function GetUI(Index:Integer):UIView;

      Property Width:Integer Read GetWidth;
      Property Height:Integer Read GetHeight;

      Property TextureAtlas:TextureAtlas Read _TextureAtlas;

      Property Ratio:Single Read _Ratio;

      Property Count:Integer Read _UICount;

      Property FontRenderer:TERRAFontRenderer Read GetFontRenderer Write SetFontRenderer;

      Property Viewport:TERRAViewport Read _Viewport;

      Property AlignEnums:EnumCollection Read _AlignEnums;
      Property DirectionEnums:EnumCollection Read _DirectionEnums;
  End;

Function GetSpriteZOnTop(W:UIWidget; Ofs:Single = 1.0):Single;

Implementation
Uses TERRA_Error, TERRA_OS, TERRA_Stream, TERRA_Renderer, TERRA_XML, TERRA_Matrix4x4,
  TERRA_Log, TERRA_FileUtils, TERRA_FileManager, TERRA_InputManager(*,
  TERRA_UIVirtualKeyboard, TERRA_UITabs, TERRA_UIScrollBar,
   TERRA_UIButton, TERRA_UISprite, TERRA_UILabel, TERRA_UIWindow,
  TERRA_UICheckbox, TERRA_UIEditText, TERRA_UIIcon*);


Var
  _UIManager_Instance:ApplicationObject = Nil;

Function GetSpriteZOnTop(W:UIWidget; Ofs:Single):Single;
Begin
  //Result := (100 - W.GetLayer()) - Ofs;
  Result := W.GetLayer() + Ofs;
End;


{ UIView }
Constructor UIView.Create;
Begin
  Inherited Create('UI', Nil);

  _Transition := Nil;

  SetTransform(MatrixIdentity3x3);

  Key_Up := TERRA_OS.keyUp;
  Key_Down := TERRA_OS.keyDown;
  Key_Right := TERRA_OS.keyRight;
  Key_Left := TERRA_OS.keyLeft;
  Key_Action := TERRA_OS.keyEnter;
  Key_Cancel := TERRA_OS.keyEscape;

  _ClipRect.Style := clipNothing;

  Self.Width := UIPixels(UIManager.Instance.Width);
  Self.Height := UIPixels(UIManager.Instance.Height);

  Self.CanReceiveEvents := True;

  UIManager.Instance.AddUI(Self);
End;

Procedure UIView.Release;
Begin
  ReleaseObject(_Transition);
End;

Procedure UIView.Clear;
Begin
  Log(logError, 'UI', 'Clearing UI');

  Self.RemoveAllChildren();

  SetTransition(Nil);
  Log(logError, 'UI', 'UI is now clear.');
End;

Procedure UIView.SetFocus(Value:UIWidget);
Begin
  If (Value = _Focus) Then
    Exit;

  If (Assigned(_Focus)) Then
  Begin
    _Focus.TriggerEvent(widgetEvent_FocusEnd);
  End;

  _Focus := Value;

  If (Assigned(_Focus)) Then
  Begin
    _Focus.TriggerEvent(widgetEvent_FocusBegin);
  End;
End;

Procedure UIView.SetDefaultFont(const Value:TERRAFont);
Begin
  FontManager.Instance.PreFetch(Value);
  Self._DefaultFont := Value;
End;

Procedure UIView.SetColorTable(Const Value:TERRATexture);
Begin
  Self._ColorTable := Value;
End;


Procedure UIView.Render(View:TERRAViewport);
Var
  Current, Temp:UIWidget;
  I, J:Integer;
  It:Iterator;
Begin
  _Draw := False;

  (* TODO
  If (Assigned(_Highlight)) And ((Not _Highlight.Visible) Or (Not _Highlight.Enabled)) Then
  Begin
    _Highlight := SelectNearestWidget(_Highlight);
  End;*)

  If (Assigned(_Focus)) And (Not _Focus.Visible) Then
    SetFocus(Nil);

  If (Assigned(_Modal)) And (Not _Modal.Visible) Then
    _Modal := Nil;

  If (_Language <> Application.Instance.Language) Then
  Begin
    _Language := Application.Instance.Language;
    Self.OnLanguageChange();
  End;

  If (UIManager.Instance._UpdateTextureAtlas) Then
    Exit;

  GraphicsManager.Instance.Renderer.SetBlendMode(blendBlend);

  Inherited Render(View);
End;

Procedure UIView.AfterEffects;
Var
  CurrentTransitionID:Cardinal;
Begin
  {If Self._CutsceneAlpha>0 Then
    DrawCutsceneBars;}

  If (Assigned(_Transition)) Then
  Begin
    CurrentTransitionID := _Transition.ID;
    // note, this is tricky, since transition update can call a callback that remove or setup a new transition
    If (Not _Transition.Update) Then
    Begin
      If (Assigned(_Transition)) And (_Transition.ID = CurrentTransitionID) Then
        SetTransition(Nil);
    End;
  End;
End;

Procedure UIView.SetTransition(MyTransition:UITransition);
Begin
  ReleaseObject(_Transition);

  _Transition := MyTransition;

  If Assigned(_Transition) Then
    _Transition.Transform := Self.Transform;
End;

Function UIView.OnKeyDown(Key:Word):UIWidget;
Begin
  Result := Nil;

	If Assigned(_Highlight) Then
  Begin
		If _Highlight.OnKeyDown(Key) Then
      Result := _Highlight;
  End;
End;

Function UIView.OnKeyUp(Key:Word):UIWidget;
Var
  I:Integer;
Begin
  Result := Nil;

	If Assigned(_Highlight) Then
  Begin
		If _Highlight.OnKeyUp(Key) Then
    Begin
      Result := _Highlight;
      Exit;
    End;
  End;

	If Assigned(_Focus) Then
  Begin
		If _Focus.OnKeyUp(Key) Then
    Begin
      Result := _Focus;
      Exit;
    End;
  End;

  For I:=0 To Pred(_ChildrenCount) Do
  If (_ChildrenList[I].Visible) And (_ChildrenList[I].OnKeyUp(Key))  Then
  Begin
    Result := _ChildrenList[I];
    Exit;
  End;
End;

Function UIView.OnKeyPress(Key:TERRAChar):UIWidget;
Begin
  Result := Nil;
  Log(logDebug, 'UI', 'keypress: '+IntToString(Integer(Key)));

	If Assigned(_Focus) Then
  Begin
    Log(logDebug, 'UI', 'focus is '+_Focus.Name);
		_Focus.OnKeyPress(Key);
    Result := _Focus;
  End;

  Log(logDebug, 'UI', 'keypress done!');
End;

Function UIView.PickWidget(X,Y:Integer; WithEventsOnly:Boolean; Ignore:UIWidget = Nil):UIWidget;
Var
  I:Integer;
  Max:Single;
Begin
  _LastWidget := Nil;

//  ConvertGlobalToLocal(X, Y);

  Result := Nil;
  Max := -9999;

  For I:=0 To Pred(_ChildrenCount) Do
  If (_ChildrenList[I].AllowsEvents) Then
  Begin
    _ChildrenList[I].PickAt(X, Y, WithEventsOnly, Result, Max, Ignore);
  End;

  If (Self.Modal<>Nil) And (Assigned(Result)) And (Not Result.IsSameFamily(Modal)) Then
  Begin
    Result := Nil;
    {$IFDEF DEBUG_GUI}Log(logDebug, 'Game', 'Cancelled because of modal...');{$ENDIF}
  End;

  //Log(logDebug, 'Game', 'Found a Widget for picking: '+CurrentPick.Name);
  _LastWidget := Result;
End;

Function UIView.OnMouseDown(X,Y:Integer;Button:Word):UIWidget;
Begin
  Result := Self.PickWidget(X,Y, True);

  If (Assigned(_Focus)) And (_Focus<>Result) Then
  Begin
    SetFocus(Nil);
  End;

  _HoldWidget := Result;
End;


Function UIView.OnMouseUp(X,Y:Integer;Button:Word):UIWidget;
Begin
  If (Assigned(Self.Dragger)) Then
  Begin
    Result := Self.Dragger;
    Self.Dragger.FinishDrag();
    Exit;
  End;

  If (Assigned(_HoldWidget)) Then
  Begin
    Result := _HoldWidget;

    If (Result.Enabled) And (Not Result.HasPropertyTweens()) Then
    Begin
      {$IFDEF DEBUG_GUI}Log(logDebug, 'UI', 'Calling onmousedown for '+Result.Name));{$ENDIF}
      Result.TriggerEvent(widgetEvent_MouseDown);
    End;

    _HoldWidget := Nil;
  End;

  Result := Self.PickWidget(X,Y, True);

  If (Assigned(Result)) And (Result.Enabled) And (Not Result.HasPropertyTweens()) Then
    Result.OnMouseUp(X, Y, Button);
End;

Function UIView.OnMouseMove(X,Y:Integer):UIWidget;
Begin
  _LastWidget := Nil;

  If (Assigned(_HoldWidget)) And (_HoldWidget.Draggable) And (Not _HoldWidget.Dragging) Then
  Begin
    Result := _HoldWidget;
    Result.BeginDrag(X,Y, UIDrag_Move);

    _HoldWidget := Nil;
    Exit;
  End;


  If Assigned(_Dragger) Then
  Begin
    _Dragger.OnMouseMove(X, Y);
    Result := _Dragger;
    _LastWidget := Result;
    Exit;
  End;

  Result := Self.PickWidget(X,Y, True);

  If (Assigned(Result)) Then
  Begin
    If (Result.Enabled) And (Not Result.HasPropertyTweens()) Then
      Result.OnMouseMove(X, Y);
  End;

  If (_LastOver <> Result) Then
  Begin
    If (Assigned(_LastOver)) Then
      _LastOver.TriggerEvent(widgetEvent_MouseOut);

    If (Assigned(Result)) Then
      Result.TriggerEvent(widgetEvent_MouseOver);

    _LastOver := Result;
  End;
End;

Function UIView.OnMouseWheel(X,Y:Integer; Delta:Integer):UIWidget;
Begin
	If Assigned(_Focus) Then
  Begin
		_Focus.OnMouseWheel(X, Y, Delta);
    Result := _Focus;
    _LastWidget := Result;
    Exit;
  End;

  Result := Self.PickWidget(X,Y, True);

  If (Assigned(Result)) And (Result.Enabled) And (Not Result.HasPropertyTweens()) Then
    Result.OnMouseWheel(X, Y, Delta);
End;

Procedure UIView.SetDragger(const Value:UIWidget);
Begin
  Self._Dragger := Value;
End;


Function UIView.GetVirtualKeyboard:UIWidget;
Begin
(*  If (_VirtualKeyboard = Nil) Then
    _VirtualKeyboard := UIVirtualKeyboard.Create('vkb', Self, 97, 'keyboard');
*)
  Result := _VirtualKeyboard;
End;

Function UIView.GetHighlight:UIWidget;
Begin
  If (Assigned(_Highlight)) And (Not _Highlight.Visible) Then
    _Highlight := Nil;

  Result := _Highlight;
End;

Function UIView.GetFontRenderer():TERRAFontRenderer;
Begin
  Result := Inherited GetFontRenderer;
(*  Result.SetFont(Self._DefaultFont);
  Result.SetTransform(Self.Transform);
  Result.SetColor(ColorWhite);
  Result.SetClipRect(_ClipRect);*)
  //Result.SetDropShadow(ColorGrey(0, 64));
End;

Function UIView.OnRegion(X, Y: Integer): Boolean;
Begin
  Result := (X>=0) And (Y>=0) And (X<=UIManager.Instance.Width) And (Y<=UIManager.Instance.Height);
End;

(*Function UIView.SelectNearestWidget(Target:UIWidget):UIWidget;
Var
  It:Iterator;
  Base:Vector2D;
  GroupID:Integer;
  Min, Dist:Single;
  W:UIWidget;
Begin
  Result := Nil;
  If Target = Nil Then
    Exit;

  Min := 99999;
  Base := Target.AbsolutePosition;
  GroupID := Target.HighlightGroup;

  It := Self.GetIterator();
  While It.HasNext() Do
  Begin
    W := UIWidget(It.Value);
    If (W = Target) Or (Not W.CanHighlight(GroupID)) Then
      Continue;

    Dist := W.AbsolutePosition.Distance(Base);
    If (Dist< Min) Then
    Begin
      Min := Dist;
      Result := W;
    End;
  End;
  ReleaseObject(It);
End;

Procedure UIView.GetFirstHighLight(GroupID:Integer);
Var
  W:UIWidget;
  It:Iterator;
Begin
  It := Self.GetIterator();
  While It.HasNext() Do
  Begin
    W := UIWidget(It.Value);
    If (Not W.CanHighlight(GroupID)) Then
      Continue;

    Self.Highlight := W;
    Break;
  End;
  ReleaseObject(It);
End;*)

Function UIView.GetModal:UIWidget;
Begin
  If (Assigned(_Modal)) And (Not _Modal.Visible) Then
  Begin
    Self.Modal := Nil;
  End;

  Result := Self._Modal;
End;

Function UIView.GetObjectType: TERRAString;
Begin
  Result := 'UI';
End;

{ UIManager }
Procedure UIManager.Init;
Var
  TargetWidth, TargetHeight:Integer;
Begin
  _TextureAtlas := Nil;
  _Ratio := 1.0;
  _UpdateTextureAtlas := False;

  _AlignEnums := EnumCollection.Create();
  _AlignEnums.Add('TopLeft', waTopLeft);
  _AlignEnums.Add('TopCenter', waTopCenter);
  _AlignEnums.Add('TopRight', waTopRight);
  _AlignEnums.Add('LeftCenter', waLeftCenter);
  _AlignEnums.Add('Center', waCenter);
  _AlignEnums.Add('RightCenter', waRightCenter);
  _AlignEnums.Add('BottomLeft', waBottomLeft);
  _AlignEnums.Add('BottomCenter', waBottomCenter);
  _AlignEnums.Add('BottomRight', waBottomRight);

  _DirectionEnums := EnumCollection.Create();
  _DirectionEnums.Add('Vertical', Integer(UIDirection_Vertical));
  _DirectionEnums.Add('Horizontal', Integer(UIDirection_Horizontal));

  // make UI view
  TargetWidth := GraphicsManager.Instance.UI_Width;
  TargetHeight := GraphicsManager.Instance.UI_Height;
  _Camera := OrthoCamera.Create('UI');
  OrthoCamera(_Camera).SetArea(0.0, TargetWidth, TargetHeight, 0.0);
  _Camera.NearDistance := -100;
  _Camera.FarDistance := 100;

  _Viewport := TERRAViewport.Create('UI', _Camera, TargetWidth, TargetHeight, {$IFDEF FRAMEBUFFEROBJECTS}GraphicsManager.Instance.UI_Scale{$ELSE}1.0{$ENDIF});
  _Viewport.BackgroundColor := ColorNull;
  _Viewport.SetRenderTargetState(captureTargetColor, True);
  _Viewport.SetTarget(GraphicsManager.Instance.DeviceViewport, 0, 0, 1.0, 1.0);

  GraphicsManager.Instance.AddViewport(_Viewport);
End;

Procedure UIManager.Release;
Var
  I:Integer;
Begin
  For I:=0 To Pred(_UICount) Do
    ReleaseObject(_UIList[I]);

  _UICount := 0;

  ReleaseObject(_FontRenderer);
  ReleaseObject(_TextureAtlas);

  ReleaseObject(_AlignEnums);

  ReleaseObject(_Camera);

  _UIManager_Instance := Nil;
End;

Procedure UIManager.AddUI(UI:UIView);
Var
  I:Integer;
Begin
  If (UI = Nil) Then
    Exit;

  For I:=0 To Pred(_UICount) Do
  If (_UIList[I] = UI) Then
    Exit;

  Inc(_UICount);
  SetLength(_UIList, _UICount);
  _UIList[Pred(_UICount)] := UI;
End;

Procedure UIManager.RemoveUI(UI:UIView);
Var
  I:Integer;
Begin
  I := 0;
  While (I<_UICount) Do
  If (_UIList[I] = UI) Then
  Begin
    _UIList[I] := _UIList[Pred(_UICount)];
    Dec(_UICount);
  End Else
    Inc(I);
End;

Procedure UIManager.Render();
Var
  Flags:Cardinal;
  Target:RenderTargetInterface;
  Graphics:GraphicsManager;
  Projection:Matrix4x4;
Begin
  {$IFDEF DEBUG_GRAPHICS}Log(logDebug, 'GraphicsManager', 'BeginUIRendering');{$ENDIF}

  Graphics := GraphicsManager.Instance;

  _Viewport.BackgroundColor := ColorNull;
  Target := _Viewport.GetRenderTarget(captureTargetColor);
  If Assigned(Target) Then
  Begin
    Target.BackgroundColor := _Viewport.BackgroundColor;
    _Viewport.SetViewArea(0, 0, Target.Width, Target.Height);
    Target.BeginCapture();

    Graphics.Renderer.SetBlendMode(blendBlend);
    Graphics.SetFog(False);
    //glEnable(GL_SCISSOR_TEST);

    Projection := Matrix4x4Ortho(0.0, _Viewport.Width, _Viewport.Height, 0.0, -100, 100);
    Projection := Matrix4x4Multiply4x4(Projection, Matrix4x4Translation(0.375, 0.375, 0.0));

    _Viewport.SetViewArea(0, 0, _Viewport.Width, _Viewport.Height);

    Graphics.Renderer.ClearBuffer((Not Assigned(Graphics.Scene)), True, True);

    UIManager.Instance.RenderUIs();

    If (Assigned(Graphics.Scene)) And (Not Application.Instance.HasFatalError) Then
      Graphics.Scene.RenderSprites(_Viewport);

    _Viewport.SpriteRenderer.Render(Projection);

    UIManager.Instance.AfterEffects();

//  glDisable(GL_SCISSOR_TEST);
  //glDisable(GL_ALPHA_TEST);

    Target.EndCapture();
  End;

  {$IFDEF DEBUG_GRAPHICS}Log(logDebug, 'GraphicsManager', 'FinishedUIRendering');{$ENDIF}
End;

Function UIManager.GetTextureAtlas: TextureAtlas;
Begin
  If (Not Assigned(_TextureAtlas)) Then
    _TextureAtlas := TERRA_TextureAtlas.TextureAtlas.Create('UI', TextureAtlasWidth, TextureAtlasHeight);

  Result := _TextureAtlas;
End;

Function UIManager.GetWidth: Integer;
Begin
  {If GraphicsManager.Instance.LandscapeOrientation Then
  Begin
    Result := GraphicsManager.Instance.Height;
  End Else
  Begin
    Result := GraphicsManager.Instance.Width;
  End;}
  Result := Self.Viewport.Width;
End;

Function UIManager.GetHeight: Integer;
Begin
  {If GraphicsManager.Instance.LandscapeOrientation Then
  Begin
    Result := GraphicsManager.Instance.Width;
  End Else
  Begin
    Result := GraphicsManager.Instance.Height;
  End;}
  Result := Self.Viewport.Height;
End;

Procedure UIManager.TextureAtlasClear();
Begin
  _UpdateTextureAtlas := True;
End;

Class Function UIManager.Instance: UIManager;
Begin
  If (_UIManager_Instance = Nil) Then
    _UIManager_Instance := InitializeApplicationComponent(UIManager, Nil);

  Result := UIManager(_UIManager_Instance.Instance);
End;

Procedure UIManager.Resume;
Begin
  _UpdateTextureAtlas := True;
End;

Procedure UIManager.RenderUIs();
Var
  I:Integer;
Begin
  If (_UpdateTextureAtlas) Then
  Begin
    Log(logDebug, 'UI', 'Updating UI TextureAtlas');

    Self.GetTextureAtlas.Update();
    _UpdateTextureAtlas := False;

    For I:=0 To Pred(_TextureAtlas.PageCount) Do
      _TextureAtlas.GetTexture(I).Filter := filterBilinear;
  End;

  For I:=0 To Pred(_UICount) Do
  If (_UIList[I].Visible) Then
    _UIList[I].Render(_Viewport);
End;

Procedure UIManager.AfterEffects;
Var
  I:Integer;
Begin
  For I:=0 To Pred(_UICount) Do
  If _UIList[I].Visible Then
    _UIList[I].AfterEffects();
End;

Procedure UIManager.OnOrientationChange;
Var
  I:Integer;
Begin
  If (Viewport = Nil) Then
    Exit;

  UpdateRatio();
  For I:=0 To Pred(_UICount) Do
    _UIList[I]._TransformChanged := True;
End;

Procedure UIManager.UpdateRatio;
Begin
 { If (IsLandscapeOrientation(Application.Instance.Orientation)) Then
    _Ratio := (Height/Width)
  Else}
    _Ratio := 1.0;
End;

Function UIManager.GetUI(Index: Integer):UIView;
Begin
  If (Index<0) Or (Index>=Count) Then
    Result := Nil
  Else
    Result := Self._UIList[Index];
End;

Procedure UIManager.SetFontRenderer(const Value:TERRAFontRenderer);
Begin
  If _FontRenderer = FontRenderer Then
    Exit;

  _FontRenderer := FontRenderer;
End;

Function UIManager.GetFontRenderer:TERRAFontRenderer;
Begin
  If _FontRenderer = Nil Then
    _FontRenderer := TERRAFontRenderer.Create();

  Result := _FontRenderer;
End;

Procedure UIManager.OnAppResize;
Var
  UIW, UIH:Integer;
Begin
  UIW := GraphicsManager.Instance.UI_Width;
  UIH := GraphicsManager.Instance.UI_Height;
  If (_Viewport.Width<>UIW) Or (_Viewport.Height<>UIH) Then
    _Viewport.Resize(UIW, UIH);
End;

Function UIManager.CreateProperty(Owner:TERRAObject; const KeyName, ObjectType: TERRAString): TERRAObject;
Begin
  If (StringEquals(ObjectType, 'UI')) Then
    Result := UIView.Create()
  Else
    Result := Nil;
End;

(*
Function UIView.LoadImage(Name:TERRAString):TextureAtlasItem;
Var
  I:Integer;
  Source, Temp:Image;
  MyStream:Stream;
  S:TERRAString;
  Ext:ImageClassInfo;
Begin
  Name := GetFileName(Name, True);

  Log(logDebug, 'UI', 'Getting '+Name);
  Result := UIManager.Instance.GetTextureAtlas.Get(Name);
  If Assigned(Result) Then
    Exit;

  Log(logDebug, 'UI', 'Searching icons');
  S := '';
  I := 0;
  While (S='') And (I<GetImageExtensionCount()) Do
  Begin
    Ext := GetImageExtension(I);
    S := FileManager.Instance.SearchResourceFile(Name+'.'+Ext.Name);
    Inc(I);
  End;

  Log(logDebug, 'Game', 'Got '+S);
  If S<>'' Then
  Begin
    Log(logDebug, 'Game', 'Opening stream');
    MyStream := FileManager.Instance.OpenStream(S);
    Log(logDebug, 'Game', 'Creating image: '+S);

    Source := Image.Create(MyStream);
    Log(logDebug, 'Game', 'Image created: '+IntToString(Source.Width)+'x'+IntToString(Source.Height));

    Log(logDebug, 'Game', 'Adding to TextureAtlas');

    Result := UIManager.Instance.GetTextureAtlas.Add(Source, Name);
    UIManager.Instance._UpdateTextureAtlas := True;

    Log(logDebug, 'Game', 'TextureAtlas added');

    ReleaseObject(Source);
    ReleaseObject(MyStream);
  End Else
  Begin
    Log(logWarning,'UI', 'UI component not found. ['+Name+']');
    Result := Nil;
  End;
End;

Function CloseMsgBox(Src:UIWidget):Boolean; Cdecl;
Var
  UI:UIView;
Begin
  Result := True;

  If (Src = Nil) Then
    Exit;

  UI := Src._UI;
  If (UI = Nil) Then
    Exit;

  If (UI.System_Wnd = Nil) Or (UI.System_Wnd.HasPropertyTweens()) Then
    Exit;

  UI.CloseWnd();

  If Assigned(UI._WndCallback1) Then
    UI._WndCallback1(Src);

  UI._WndCallback1 := Nil;
  UI._WndCallback2 := Nil;
End;

Function CloseMsgBox2(Src:Widget):Boolean; Cdecl;
Var
  UI:UIView;
Begin
  Result := True;

  If (Src = Nil) Then
    Exit;

  UI := Src._UI;
  If (UI = Nil) Then
    Exit;

  If (UI.System_Wnd = Nil) Or (UI.System_Wnd.HasPropertyTweens()) Then
    Exit;

  UI.CloseWnd();

  If Assigned(UI._WndCallback2) Then
    UI._WndCallback2(Src);

  UI._WndCallback1 := Nil;
  UI._WndCallback2 := Nil;
End;

Procedure UIView.InitTempWidgets();
Var
  N,I:Integer;
//TODO  S:UISprite;
Begin
  System_Wnd := UIWindow(GetWidget(System_Name_Wnd));
  System_Text := UILabel(GetWidget(System_Name_Text));
  For I:=0 To 2 Do
    System_Btn[I] := UIButton(GetWidget(System_Name_Btn+IntToString(I)));

  If Not Assigned(System_Wnd) Then
  Begin
    System_Wnd := UIWindow.Create(System_Name_Wnd, Self, Nil, 0, 0, 97, UIPixels(500), UIPixels(200));
    System_Wnd.Visible := False;
    System_Text := UILabel.Create(System_Name_Text, Self, System_Wnd, 20, 20, 0.5, '??');
    For I:=0 To 2 Do
    Begin
      Case I Of
      0:  N := 0;
      1:  N := -100;
      2:  N := 100;
      Else
      	N := 0;
      End;

      System_Btn[I] := UIButton.Create(System_Name_Btn+IntToString(I), Self, System_Wnd, N, 20, 0.5, 'Ok');
      System_Btn[I].Align := waBottomCenter;
    End;
  End;

  System_BG := UISprite(GetWidget(System_Name_BG));
  If Not Assigned(System_BG) Then
  Begin
    S := UISprite.Create(System_Name_BG, Self, Nil, 0, 0, 96.5);
    S.Rect.Texture := TextureManager.Instance.WhiteTexture;
    S.Rect.Width := UIManager.Instance.Width;
    S.Rect.Height := UIManager.Instance.Height;
    S.Color := ColorGrey(0, 100);
    S.Visible := False;
    System_BG := S;
  End;
End;

Procedure UIView.InitStuff();
Var
  I:Integer;
Begin
  InitTempWidgets();
  System_Wnd.Align := waCenter;
  Modal := System_Wnd;

  System_BG.Visible := True;
  System_Wnd.Visible := True;

  For I:=0 To 2 Do
    System_Btn[I].OnMouseClick := CloseMsgBox;
    TODO

  System_Btn[2].OnMouseClick := CloseMsgBox2;
End;

Procedure UIView.MessageBox(Msg:TERRAString; Callback: WidgetEventHandler);
Var
  I:Integer;
Begin
  _WndCallback1 := Callback;
  InitStuff();

  TODO
  UILabel(System_Text).Caption := Msg;
  For I:=0 To 2 Do
    System_Btn[I].Visible := (I=0);

  _PrevHighlight := Highlight;
  If (Highlight<>Nil) Then
    Highlight := System_Btn[0];
End;


Procedure UIView.ChoiceBox(Msg, Option1, Option2:TERRAString; Callback1:WidgetEventHandler = Nil; Callback2: WidgetEventHandler = Nil);
Var
  I:Integer;
Begin
  _WndCallback1 := Callback1;
  _WndCallback2 := Callback2;
  InitStuff();

  (*TODO
  UILabel(System_Text).Caption := System_Text._FontRenderer.AutoWrapText(Msg, System_Wnd.Size.X - 30);
  For I:=0 To 2 Do
    System_Btn[I].Visible := (I>0);

  UIButton(System_Btn[1]).Caption := Option1;
  UIButton(System_Btn[2]).Caption := Option2;

  _PrevHighlight := Highlight;
    Highlight := System_Btn[1];
End;

Procedure UIView.ShowModal(W:Widget);
Begin
  If W = Nil Then
    Exit;

  InitTempWidgets();
  System_BG.Visible := True;

  If Not W.Visible Then
    W.Visible := True;

  Modal := W;

  If (Highlight<>Nil) Then
    Highlight := W;
End;

Procedure UIView.ClearChoiceBox();
Begin
  Modal := Nil;

  If Assigned(System_BG) Then
    System_BG.Visible := False;

  If Assigned(System_Wnd) Then
    System_Wnd.Visible := False;
End;

Procedure UIView.CloseWnd();
Begin
  System_BG.Visible := False;
  System_Wnd.Visible := False;
  //MsgWnd.Hide(widgetAnimateAlpha);

  Modal := Nil;
  Highlight := _PrevHighlight;
End;


*)

Procedure UIManager.AddController(Controller: UIController);
Begin
  Inc(_ControllerCount);
  SetLength(_Controllers, _ControllerCount);
  _Controllers[Pred(_ControllerCount)] := Controller;
End;

Function UIManager.GetControllerByName(Const Name:TERRAString): UIController;
Var
  I:Integer;
Begin
  For I:=0 To Pred(_ControllerCount) Do
  If (StringEquals(_Controllers[I].Name, Name)) Then
  Begin
    Result := _Controllers[I];
    Exit;
  End;

  Result := Nil;
End;

End.
