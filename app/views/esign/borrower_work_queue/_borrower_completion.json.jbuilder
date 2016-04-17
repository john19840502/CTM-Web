json.extract! borrower_completion, :id, :loan_number, :assignee, :product
json.status borrower_completion.status || "To be reviewed"
json.completed borrower_completion.complete?
json.extract! borrower_completion.esign_signer, :full_name, :esign_completed_date
json.update_path "/esign/borrower_work_queue/#{borrower_completion.id}/update"
json.assignment_error false