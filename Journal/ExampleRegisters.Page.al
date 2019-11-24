page 50017 "Example Registers"
{
    Caption = 'Example Registers';
    Editable = false;
    PageType = List;
    SourceTable = "Example Register";
    UsageCategory = History;
    ApplicationArea = All;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                field("No."; "No.")
                {
                    ApplicationArea = All;
                }
                field("Creation Date"; "Creation Date")
                {
                    ApplicationArea = All;
                }
                field("User ID"; "User ID")
                {
                    ApplicationArea = All;
                }
                field("Source Code"; "Source Code")
                {
                    ApplicationArea = All;
                }
                field("Journal Batch Name"; "Journal Batch Name")
                {
                    ApplicationArea = All;
                }
                field("From Entry No."; "From Entry No.")
                {
                    ApplicationArea = All;
                }
                field("To Entry No."; "To Entry No.")
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
        area(navigation)
        {
            group("&Register")
            {
                Caption = '&Register';
                Image = Register;
                // action("Example Ledger")
                // {
                //   Caption='Example Ledger';
                //   Image=ResourceLedger;
                //   Promoted=true;
                //   PromotedCategory=Process;
                //   PromotedIsBig=true;
                //   RunObject=Codeunit 50009;
                // }
            }
        }
    }
}

