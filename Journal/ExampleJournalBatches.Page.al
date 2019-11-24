page 50016 "Example Jnl. Batches"
{
    Caption = 'Example Jnl. Batches';
    DataCaptionExpression = DataCaption;
    PageType = List;
    SourceTable = "Ex. Journal Batch";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                field(Name; Name)
                {
                    ApplicationArea = All;
                }
                field(Description; Description)
                {
                    ApplicationArea = All;
                }
                field("No. Series"; "No. Series")
                {
                    ApplicationArea = All;
                }
                field("Posting No. Series"; "Posting No. Series")
                {
                    ApplicationArea = All;
                }
                field("Reason Code"; "Reason Code")
                {
                    ApplicationArea = All;
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
        area(processing)
        {
            action("Edit Journal")
            {
                ApplicationArea = All;
                Caption = 'Edit Journal';
                Image = OpenJournal;
                Promoted = true;
                PromotedCategory = Process;
                PromotedIsBig = true;
                ShortCutKey = 'Return';

                trigger OnAction();
                begin
                    ExJnlMgt.TemplateSelectionFromBatch(Rec);
                end;
            }
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
                        //ReportPrint.PrintResJnlBatch(Rec); To Do
                    end;
                }
                action("P&ost")
                {
                    ApplicationArea = All;
                    Caption = 'P&ost';
                    Image = PostOrder;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    RunObject = Codeunit "Ex. Jnl.-B.Post";
                    ShortCutKey = 'F9';
                }
                action("Post and &Print")
                {
                    ApplicationArea = All;
                    Caption = 'Post and &Print';
                    Image = PostPrint;
                    Promoted = true;
                    PromotedCategory = Process;
                    PromotedIsBig = true;
                    RunObject = Codeunit "Ex. Jnl.-B.Post+Print";
                    ShortCutKey = 'Shift+F9';
                }
            }
        }
    }

    trigger OnInit();
    begin
        SetRange("Journal Template Name");
    end;

    trigger OnNewRecord(BelowxRec: Boolean);
    begin
        SetupNewBatch;
    end;

    trigger OnOpenPage();
    begin
        ExJnlMgt.OpenJnlBatch(Rec);
    end;

    var
        ExJnlMgt: Codeunit ExJnlManagement;

    local procedure DataCaption(): Text[250];
    var
        ExJnlTemplate: Record "Ex. Journal Template";
    begin
        if NOT CurrPage.LookupMode then
            if GetFilter("Journal Template Name") <> '' then
                if GetRangeMin("Journal Template Name") = GetRangeMax("Journal Template Name") then
                    if ExJnlTemplate.Get(GetRangeMin("Journal Template Name")) then
                        exit(ExJnlTemplate.Name + ' ' + ExJnlTemplate.Description);
    end;
}

