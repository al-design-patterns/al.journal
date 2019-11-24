report 50011 "Example Register"
{
    UsageCategory = ReportsAndAnalysis;
    ApplicationArea = All;
    Caption = 'Example Register';

    dataset
    {
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(PrintResourceDescriptions; 'PrintResourceDescriptions')
                    {
                        ApplicationArea = All;
                        Caption = 'Print Resource Desc.';
                    }
                }
            }
        }

        actions
        {
        }
    }



}

