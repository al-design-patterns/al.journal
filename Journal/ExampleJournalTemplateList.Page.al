page 50015 "Ex. Journal Template List"
{
    Caption = 'Ex. Journal Template List';
    Editable = false;
    PageType = List;
    RefreshOnActivate = true;
    SourceTable = "Ex. Journal Template";
    ApplicationArea = All;
    UsageCategory = Lists;

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
                field(Recurring; Recurring)
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Source Code"; "Source Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Reason Code"; "Reason Code")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Page ID"; "Page ID")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Test Report ID"; "Test Report ID")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Posting Report ID"; "Posting Report ID")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Force Posting Report"; "Force Posting Report")
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
    }
}

