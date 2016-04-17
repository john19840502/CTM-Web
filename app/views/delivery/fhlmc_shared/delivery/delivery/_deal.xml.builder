builder.DEAL do
  render partial: 'collaterals', locals: { loan: loan, builder: builder }
  builder.LOANS do
    render partial: 'combined_ltvs', locals: { loan: loan, builder: builder }
    render partial: 'loan_at_closing', locals: { loan: loan, builder: builder }
    render partial: 'current_loan', locals: { loan: loan, builder: builder }
    render partial: 'related_loan', collection: loan.subordinate_loans, as: :loan, locals: { builder: builder } #CTMWEB 2125 removed this feature
  end
  render partial: 'loan_parties', locals: { loan: loan, builder: builder}
end