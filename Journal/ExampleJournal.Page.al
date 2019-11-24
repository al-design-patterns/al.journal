page 50013 "Example Journal"
{
    AutoSplitKey = true;
    Caption = 'Example Journal';
    DataCaptionFields = "Journal Batch Name";
    DelayedInsert = true;
    PageType = Worksheet;
    SaveValues = true;
    SourceTable = "Ex. Journal Line";
    UsageCategory = Tasks;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            field(CurrentJnlBatchName; CurrentJnlBatchName)
            {
                ApplicationArea = All;
                Caption = 'Batch Name';
                Lookup = true;

                trigger OnLookup(var Text: Text): Boolean;
                begin
                    CurrPage.SaveRecord();
                    ExJnlManagement.LookupName(CurrentJnlBatchName, Rec);
                    CurrPage.Update(false);
                end;

                trigger OnValidate();
                begin
                    ExJnlManagement.CheckName(CurrentJnlBatchName, Rec);
                    CurrentJnlBatchNameOnAfterVali;
                end;
            }
            repeater(Control1)
            {
                field("Posting Date"; "Posting Date")
                {
                    ApplicationArea = All;
                }
                field("Document Date"; "Document Date")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Entry Type"; "Entry Type")
                {
                    ApplicationArea = All;
                }
                field("Document No."; "Document No.")
                {
                    ApplicationArea = All;
                }
                field("External Document No."; "External Document No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("Shortcut Dimension 1 Code"; "Shortcut Dimension 1 Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Shortcut Dimension 2 Code"; "Shortcut Dimension 2 Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("ShortcutDimCode[3]"; ShortcutDimCode[3])
                {
                    ApplicationArea = All;
                    CaptionClass = '1,2,3';
                    Visible = false;

                    trigger OnLookup(var Text: Text): Boolean;
                    begin
                        LookupShortcutDimCode(3, ShortcutDimCode[3]);
                    end;

                    trigger OnValidate();
                    begin
                        ValidateShortcutDimCode(3, ShortcutDimCode[3]);
                    end;
                }
                field("ShortcutDimCode[4]"; ShortcutDimCode[4])
                {
                    ApplicationArea = All;
                    CaptionClass = '1,2,4';
                    Visible = false;

                    trigger OnLookup(var Text: Text): Boolean;
                    begin
                        LookupShortcutDimCode(4, ShortcutDimCode[4]);
                    end;

                    trigger OnValidate();
                    begin
                        ValidateShortcutDimCode(4, ShortcutDimCode[4]);
                    end;
                }
                field("ShortcutDimCode[5]"; ShortcutDimCode[5])
                {
                    ApplicationArea = All;
                    CaptionClass = '1,2,5';
                    Visible = false;

                    trigger OnLookup(var Text: Text): Boolean;
                    begin
                        LookupShortcutDimCode(5, ShortcutDimCode[5]);
                    end;

                    trigger OnValidate();
                    begin
                        ValidateShortcutDimCode(5, ShortcutDimCode[5]);
                    end;
                }
                field("ShortcutDimCode[6]"; ShortcutDimCode[6])
                {
                    ApplicationArea = All;
                    CaptionClass = '1,2,6';
                    Visible = false;

                    trigger OnLookup(var Text: Text): Boolean;
                    begin
                        LookupShortcutDimCode(6, ShortcutDimCode[6]);
                    end;

                    trigger OnValidate();
                    begin
                        ValidateShortcutDimCode(6, ShortcutDimCode[6]);
                    end;
                }
                field("ShortcutDimCode[7]"; ShortcutDimCode[7])
                {
                    ApplicationArea = All;
                    CaptionClass = '1,2,7';
                    Visible = false;

                    trigger OnLookup(var Text: Text): Boolean;
                    begin
                        LookupShortcutDimCode(7, ShortcutDimCode[7]);
                    end;

                    trigger OnValidate();
                    begin
                        ValidateShortcutDimCode(7, ShortcutDimCode[7]);
                    end;
                }
                field("ShortcutDimCode[8]"; ShortcutDimCode[8])
                {
                    ApplicationArea = All;
                    CaptionClass = '1,2,8';
                    Visible = false;

                    trigger OnLookup(var Text: Text): Boolean;
                    begin
                        LookupShortcutDimCode(8, ShortcutDimCode[8]);
                    end;

                    trigger OnValidate();
                    begin
                        ValidateShortcutDimCode(8, ShortcutDimCode[8]);
                    end;
                }
                field("Gen. Bus. Posting Group"; "Gen. Bus. Posting Group")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Gen. Prod. Posting Group"; "Gen. Prod. Posting Group")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field(Quantity; Quantity)
                {
                    ApplicationArea = All;
                }
                field("Reason Code"; "Reason Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
            }
        }
        area(factboxes)
        {
            systempart(Links; Links)
            {
                ApplicationArea = All;
            }
            systempart(Notes; Notes)
            {
                ApplicationArea = All;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Line")
            {
                Caption = '&Line';
                Image = Line;
                action(Dimensions)
                {
                    ApplicationArea = All;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    ShortCutKey = 'Shift+Ctrl+D';

                    trigger OnAction();
                    begin
                        ShowDimensions;
                        CurrPage.SAVERECORD;
                    end;
                }
            }
        }
        area(processing)
        {
            group("P&osting")
            {
                Caption = 'P&osting';
                Image = Post;
                action("Test Report")
                {
                    ApplicationArea = All;
                    Caption = 'Test Report';
                    Ellipsis = true;
                    Image = TestReport;

                    trigger OnAction();
                    begin
                        Message('');
                        //ReportPrint.PrintResJnlLine(Rec); To Do
                    end;
                }
                action(Post)
                {
                    ApplicationArea = All;
                    Caption = 'P&ost';
                    Image = PostOrder;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortCutKey = 'F9';

                    trigger OnAction();
                    begin
                        Codeunit.Run(Codeunit::"Ex. Jnl.-Post", Rec);
                        CurrentJnlBatchName := GetRangeMax("Journal Batch Name");
                        CurrPage.Update(false);
                    end;
                }
                action("Post and &Print")
                {
                    ApplicationArea = All;
                    Caption = 'Post and &Print';
                    Image = PostPrint;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    ShortCutKey = 'Shift+F9';

                    trigger OnAction();
                    begin
                        Codeunit.Run(Codeunit::"Ex. Jnl.-Post+Print", Rec);
                        CurrentJnlBatchName := GetRangeMax("Journal Batch Name");
                        CurrPage.Update(false);
                    end;
                }
            }
        }
    }

    // trigger OnAfterGetCurrRecord(); // To Do -> Implementation Pattern
    // begin
    //     ExJnlManagement.GetEx("Example Person No.", ExName);
    // end;

    trigger OnAfterGetRecord();
    begin
        ShowShortcutDimCode(ShortcutDimCode);
    end;

    trigger OnNewRecord(BelowxRec: Boolean);
    begin
        SetUpNewLine(xRec);
        Clear(ShortcutDimCode);
    end;

    trigger OnOpenPage();
    var
        JnlSelected: Boolean;
    begin
        OpenedFromBatch := ("Journal Batch Name" <> '') AND ("Journal Template Name" = '');
        if OpenedFromBatch then begin
            CurrentJnlBatchName := "Journal Batch Name";
            ExJnlManagement.OpenJnl(CurrentJnlBatchName, Rec);
            exit;
        end;
        ExJnlManagement.TemplateSelection(PAGE::"Example Journal", FALSE, Rec, JnlSelected);
        if NOT JnlSelected then
            Error('');
        ExJnlManagement.OpenJnl(CurrentJnlBatchName, Rec);
    end;

    var
        ExJnlManagement: Codeunit ExJnlManagement;
        CurrentJnlBatchName: Code[10];
        ShortcutDimCode: array[8] of Code[20];
        OpenedFromBatch: Boolean;

    local procedure CurrentJnlBatchNameOnAfterVali();
    begin
        CurrPage.SaveRecord;
        ExJnlManagement.SetName(CurrentJnlBatchName, Rec);
        CurrPage.Update(false);
    end;
}

