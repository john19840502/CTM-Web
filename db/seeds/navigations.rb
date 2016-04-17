shared_mers_menu = {
  'Data Imports' => {
  'Mers Monthly Data' => 'compliance_mers_mers_imports_path',
  'DMI Monthly Data' => 'compliance_mers_dmi_imports_path',
  'Acquired Loans Source' => 'compliance_mers_acquired_loan_source_imports_path',
  'DMI Xref Imports' => 'compliance_mers_dmi_xref_imports_path'
  },
  'Reconciliation' => 'compliance_mers_reconciliation_reports_path',
  'Biennial Reviews' => 'compliance_mers_biennial_reviews_path',
  'MERS Organizations' => 'compliance_mers_mers_orgs_path',
  'Exception List' => 'compliance_mers_exception_list_index_path'
}

shared_rego_menu = {
  'Reg 0 Reports' => 'compliance_rego_rego_reports_path',
  'CT Executives' => 'compliance_rego_ctm_execs_path'
}
shared_uw_menu = {
  'Validation / Final Approval' => 'underwriter_validations_path',
  'Product Data' => 'underwriter_product_data_path',
  'Product Guidelines' => 'underwriter_product_guidelines_path',
  'Bulk Validation Report' => 'validation_reports_bpm_statistic_reports_path',
  'Florida Condo PERS list' => 'florida_condo_pdfs_path'
}
ops_menu = {
  'Originator Status' => 'originators_path',
  'Institution Status' => 'institutions_path'
}

registration_menu = {
  'Registration Validation' => 'registration_validations_path',
  #'Forced Registrations'    => 'registration_forced_registrations_path',
  'Reports'                 => {
    'FCRA Daily'  => 'fcra_daily_report_path',
    'EConsent on Cancelled, Denied, or Withdrawn Loans' => 'registration_esign_consent_index_path'
  }

}

client_services_menu = {
  'Reports' => {
    'Conditions Pending Review' => 'reg_b_uw_conditions_pending_review_path'
  }
}
preclosing_menu ={
'PreClosing Validations' => 'preclosing_validations_path'

}
closing_menu = {
  'Validations' => 'closing_validations_path',
  'Loan Modelers' => 'closing_loan_modelers_path',
  'Florida Condo PERS list' => 'florida_condo_pdfs_path',
  'Reports'                 => {
    'Monthly Defect Report' => 'reports_closing_settlement_agent_audits_path',
    'Month to Month Comparision Report' => 'comparision_report_closing_settlement_agent_audits_path',
    'Closing Checklist Report' => 'closing_checklist_report_path'
  }
}

suspense_menu = {
  'Closing Validations' => 'closing_validations_path'
}

funding_menu = {
  'Funding Checklist' => 'funding_validations_path',
  'Reports' => {
    'Funding Checklist Report' => 'funding_reports_path',
    'Comparision Report' => 'comparision_funding_reports_path'
  }
}

hr_menu = {
  'Commission Plan Details' => 'accounting_commission_plan_details_path',
  'Branch Compensations' => {
    'Loans' => 'core_loans_path',
    'Branches' => 'core_institutions_path',
    'Employees' => 'core_originators_path'
  }
}

sales_menu = {
  'Regions' => 'accounting_regions_path'
}

accounting_menu = {
  'Scheduled Funding' => 'accounting_scheduled_fundings_path',
  'Commissions' => {
    'Reporting' => {
      'Branch Commissions' => 'accounting_branch_commission_reports_path',
      'Commission Plan Details' => 'accounting_commission_plan_details_path'
      },
    'Branch Compensations' => {
      'Loans' => 'core_loans_path',
      'Branches' => 'core_institutions_path',
      'Employees' => 'core_originators_path'
       },
     },
  'TSS' => {
    'Sellers' => {
      'Contracts' => 'tss_commitment_contracts_path',
      'Sellers' => 'tss_sellers_path'
      },
    'Pricing' => {
      'Pricing Grid' => 'tss_pricing_grids_path',
      'Indices' => 'tss_indices_path',
      'Import Pricing Grids' => 'tss_pricing_grid_imports_path'
      },
    'Products' => 'tss_products_path',
    'Imports' => {
      'Cash' => {
        'FNMA Whole Loan Files' => 'tss_fnma_whole_loan_files_path',
        'FNMA Purchase Advice Files' => 'tss_fnma_purchase_advice_files_path',
        },
      'MBS' => {
        'MBS Detail File' => 'tss_mbs_ci_details_path',
        'MBS Summary File' => 'tss_mbs_ci_summaries_path'
      },
      'Seller Loan Files' => 'tss_seller_loans_files_path',
      'Escrows Received' => 'tss_escrow_received_uploads_path'
      },
    'Purchase Advice Reconciliation' => 'tss_purchase_advice_reconciliation_index_path',
    'Reports' => {
      'Accounting Reports' => {
        'Escrow Reports' => 'tss_reports_escrow_reports_path',
        'TSS Accounting Reports' => 'tss_reports_tss_accounting_reports_path',
        'Purchase Advice Reports' => 'tss_reports_purchase_advice_reports_path',
        'Purchase Advice Reconciliation Reports' => 'tss_reports_purchase_advice_reconciliation_reports_path',
        'Capitalization Report' => 'tss_reports_capitalization_reports_path',
        'Boarded Escrow Reports' => 'tss_reports_boarded_escrow_path'
      },
      'Secondary Reports' => {
        'Active Contract Reports' => 'tss_reports_active_contracts_reports_path',
        'Boarding Reports' => 'tss_reports_boarding_reports_path'
      },
      'TSS Loans' => {
        'General Loan Info' => 'tss_reports_purchased_date_ancillary_reports_path'
      }
    }
  },
}

init_disclose_menu = {
  'Initial Disclosure Validation' => 'root_initial_disclosure_validations_path',
  'Initial Disclosure Work Queue' => 'initial_disclosure_work_queue_index_path'
}

sys_admin_menu = {
  'Usage Stats' => 'controllers_admin_usage_stats_path'
}

secmar_menu = {
  'TSS' => {
    'Dashboard' => 'tss_dashboard_index_path',
    'Sellers' => {
      'Contracts' => 'tss_commitment_contracts_path',
      'Sellers' => 'tss_sellers_path'
    },
    'Pricing' => {
      'Pricing Grid' => 'tss_pricing_grids_path',
      'Indices' => 'tss_indices_path',
      'Adjusters' => 'tss_adjusters_path',
      'Loan Prices' => 'tss_loan_prices_path',
      'SRP Premium Groups' => 'tss_premium_sets_path',
      'Import Pricing Grids' => 'tss_pricing_grid_imports_path'
    },
    'Products' => 'tss_products_path',
    'Reports' => {
      'Accounting Reports' => {
        'Escrow Reports' => 'tss_reports_escrow_reports_path',
        'TSS Accounting Reports' => 'tss_reports_tss_accounting_reports_path',
        'Purchase Advice Reports' => 'tss_reports_purchase_advice_reports_path',
        'Purchase Advice Reconciliation Reports' => 'tss_reports_purchase_advice_reconciliation_reports_path',
        'Capitalization Report' => 'tss_reports_capitalization_reports_path',
        'Boarded Escrow Reports' => 'tss_reports_boarded_escrow_path'
      },
      'Secondary Reports' => {
        'Active Contract Reports' => 'tss_reports_active_contracts_reports_path',
        'Boarding Reports' => 'tss_reports_boarding_reports_path'
      },
      'TSS Loans' => {
        'General Loan Info' => 'tss_reports_purchased_date_ancillary_reports_path'
      },
    },
    'Imports' =>{
      'Escrows Received' => 'tss_escrow_received_uploads_path'
    }
  },
  'Imports' => {
  'Investor Imports' => 'investor_pricing_imports_path'
  },
  'Jumbo Ops Reports' => 'credit_suisse_ops_reports_path'
}

delivery_menu = {
  'Redwood' => 'delivery_redwood_loans_path',
  'FNMA Pool' => 'delivery_fnma_loans_path',
  'FNMA Cash' => 'delivery_fnma_cash_index_path',
  'GNMA Pool' => 'delivery_gnma_loans_path',
  'FHLMC Pool' => 'delivery_fhlmc_pools_path',
  'FHLMC Cash' => 'delivery_fhlmc_cash_index_path',
  'FHLMC Individual' => 'delivery_fhlmc_individuals_path',
  'FHLB Pool' => 'delivery_fhlb_pools_path',
}

credit_menu = {
  'TSS' => {
  'Sellers' => {
    'Contracts' => 'tss_commitment_contracts_path',
    'Sellers' => 'tss_sellers_path'
    },
  'Reports' => {
    'Accounting Reports' => {
      'Escrow Reports' => 'tss_reports_escrow_reports_path',
      'TSS Accounting Reports' => 'tss_reports_tss_accounting_reports_path',
      'Purchase Advice Reports' => 'tss_reports_purchase_advice_reports_path',
      'Purchased Date Ancillary Reports' => 'tss_reports_purchased_date_ancillary_reports_path',
      'Capitalization Report' => 'tss_reports_capitalization_reports_path'
      },
    'Secondary Reports' => {
      'Active Contract Reports' => 'tss_reports_active_contracts_reports_path',
      'Boarding Reports' => 'tss_reports_boarding_reports_path'
      },
    'TSS Loans' => {
      'General Loan Info' => 'tss_reports_purchased_date_ancillary_reports_path'
      }
    }
  },
  'Florida Condo PERS list' => 'florida_condo_pdfs_path'
}

serva_menu = {
  'TSS' => {
    'Dashboard' => 'tss_dashboard_index_path',
    'Sellers' => {
      'Contracts' => 'tss_commitment_contracts_path',
      'Sellers' => 'tss_sellers_path'
      },
    'Pricing' => {
      'Pricing Grid' => 'tss_pricing_grids_path',
      'Indices' => 'tss_indices_path',
      'Loan Prices' => 'tss_loan_prices_path',
      'Import Pricing Grids' => 'tss_pricing_grid_imports_path'
      },
  'Products' => 'tss_products_path',
  'Imports' => {
    'Cash' => {
      'FNMA Whole Loan Files' => 'tss_fnma_whole_loan_files_path',
      'FNMA Purchase Advice Files' => 'tss_fnma_purchase_advice_files_path',
    },
    'MBS' => {
      'MBS Detail File' => 'tss_mbs_ci_details_path',
      'MBS Summary File' => 'tss_mbs_ci_summaries_path'
    },
    'Blitz' =>{
      'Loan File Uploaded' => 'tss_blitz_loan_file_uploads_path',
    },
    'MERS' =>{
      'MERS Batch Approval Dates' => 'tss_mers_batch_approval_dates_path',
    },
    'Seller Loan Files' => 'tss_seller_loans_files_path',
    'Escrows Received' => 'tss_escrow_received_uploads_path'
    },
  'Reconciliation' => {
    'Pending Loans' => 'tss_missing_loans_path',
    'Validated Loans' => 'tss_validated_index_path'
    },
  'Purchase Advice Reconciliation' => 'tss_purchase_advice_reconciliation_index_path',
  'Boarding' => {
    'Select Loans' => 'tss_approved_index_path',
    'Boarding Files' => 'tss_boarded_files_path'
    },
  'Reports' => {
    'Accounting Reports' => {
      'Escrow Reports' => 'tss_reports_escrow_reports_path',
      'TSS Accounting Reports' => 'tss_reports_tss_accounting_reports_path',
      'Purchase Advice Reports' => 'tss_reports_purchase_advice_reports_path',
      'Purchase Advice Reconciliation Reports' => 'tss_reports_purchase_advice_reconciliation_reports_path',
      'Capitalization Report' => 'tss_reports_capitalization_reports_path',
      'Boarded Escrow Reports' => 'tss_reports_boarded_escrow_path'
      },
    'Secondary Reports' => {
      'Active Contract Reports' => 'tss_reports_active_contracts_reports_path',
      'Boarding Reports' => 'tss_reports_boarding_reports_path',
      'Unfulfilled Contracts' => 'tss_reports_unfulfilled_contract_path'
      },
    'TSS Loans' => {
      'General Loan Info' => 'tss_reports_purchased_date_ancillary_reports_path'
      },
    },
  'Letters' => {
    'Hello Letters' => 'tss_hello_letters_path'
    }
  }
}

compliance_menu = {
  'MERS' => shared_mers_menu,
  'Reg 0' => shared_rego_menu,
  'HMDA' => {
    'Reportable Events' => 'compliance_hmda_loan_compliance_events_path',
    'Purchased Loans' => 'compliance_hmda_purchased_loans_path',
    'Investor Codes' => 'compliance_hmda_hmda_investor_codes_path',
    'Exceptions' => 'compliance_hmda_loan_compliance_exceptions_path',
    'Exception Reports' => 'compliance_hmda_loan_compliance_exception_reports_path',
    'Report Filters' => 'compliance_hmda_loan_compliance_filters_path',
    'Quarterly / Annual Process' => 'compliance_hmda_quarterly_annuals_path',
    'Data Change Report' => 'compliance_hmda_data_change_reports_path',
    'HPML Loans report' => 'hpml_results_path',
    'Non-reportable loans' => 'compliance_hmda_loan_compliance_non_reportables_path'
  },
}

enterprise_compliance_lob_menu = {
  'Flood Cert Report' => 'ssrs_enterprise_compliance_flood_compliance_review_path'
}

risk_menu = {
  'MERS' => shared_mers_menu,
  'Reg 0' => shared_rego_menu
}

servicing_menu = {
  'MERS' => shared_mers_menu,
  'TSS' => {
    'Sellers' => {
      'Contracts' => 'tss_commitment_contracts_path',
      'Sellers' => 'tss_sellers_path'
      },
    'Products' => 'tss_products_path',
    'Boarding' => {
      'Select Loans' => 'tss_approved_index_path',
      'Generate Boarding File' => 'tss_boarded_files_path'
      },
    'Reports' => {
      'Accounting Reports' => {
        'Purchase Advice Reports' => 'tss_reports_purchase_advice_reports_path',
        'Purchase Advice Reconciliation Reports' => 'tss_reports_purchase_advice_reconcilaition_reports_path'
        },
      'Secondary Reports' => {
        'Boarding Reports' => 'tss_reports_boarding_reports_path',
        'Unfulfilled Contracts' => 'tss_reports_unfulfilled_contract_path'
        },
      'TSS Loans' => {
        'General Loan Info' => 'tss_reports_purchased_date_ancillary_reports_path'
        }
      },
    'Imports' => {
      'Blitz' => {
        'Loan File Uploaded' => 'tss_blitz_loan_file_uploads_path',
        },
      'Escrows Received' => 'tss_escrow_received_uploads_path'
      }
    },
    'Fiserv' => {
      'LOI Files' => 'servicing_boarding_files_path',
      'Manual Boarding' => 'servicing_manual_boarding_index_path',
    },
  }

  lockdesk_menu = {
    'Credit Suisse Exports' => 'credit_suisse_lock_exports_path',
    'Jumbo Ops Reports' => 'credit_suisse_ops_reports_path'

  }
  pac_menu = {
    'Credit Suisse Exports' => 'credit_suisse_appraisal_exports_path',
    'Jumbo Ops Reports' => 'credit_suisse_ops_reports_path'
  }
  postclosing_menu = {
    'Credit Suisse Exports' => {
      'Post Purchase' => 'credit_suisse_funding_exports_path',
      'Purchase' => 'credit_suisse_post_closing_exports_path'
      },
    'Jumbo Ops Reports' => 'credit_suisse_ops_reports_path'

  }
  uw_menu = {
    'Underwriter' => shared_uw_menu,
    'Credit Suisse Exports' => 'credit_suisse_appraisal_exports_path',
    'Jumbo Ops Reports'     => 'credit_suisse_ops_reports_path',
    'UW Dashboard'          => 'bpm_statistic_reports_path',
    'Underwriting Reports' => {
        'UW Submitted'              => 'reg_b_uw_submitted_path',
        'UW Received'               => 'reg_b_uw_received_path',
        'Conditions Pending Review' => 'reg_b_uw_conditions_pending_review_path',
        'Pending Second Review'     => 'reg_b_uw_pending_second_review_path',
        'File Incomplete'           => 'reg_b_file_incomplete_conditions_path',
        'Waived Conditions'         => 'reg_b_waived_conditions_path'
    }
  }
  bpm_menu = {
    'Statistic Reports' => {
      'Categorized Validation Errors' => 'bpm_statistic_reports_path',
      'General Assigned Underwriter Data' => 'bpm_statistic_reports_path',
      'General Loan Data' => 'bpm_statistic_reports_path'
    }
  }

  evening_menu = {
    'TSS' => {
      'Hello Letters' => 'tss_hello_letters_path',
      },
    'Fiserv' => {
        'LOI Files' => 'servicing_boarding_files_path',
      },
    }

  title_vendors_menu = {
    'Title Vendors' => 'vendors_path',
    'Vendors By State' => 'state_title_vendors_path'
  }

Navigation.delete_all # delete all nav and re-build.
# Subdomain.all

Navigation.make_main_menu 'accounting','Accounting', accounting_menu
Navigation.make_main_menu 'admin','System Adminstration', sys_admin_menu
Navigation.make_main_menu 'bpm','BPM',        bpm_menu
Navigation.make_main_menu 'regb_clientam_srvs', 'Client Services', client_services_menu
Navigation.make_main_menu 'closing','Closing',      closing_menu
Navigation.make_main_menu 'compliance','Compliance', compliance_menu
Navigation.make_main_menu 'credit_risk','Credit Risk',     credit_menu
Navigation.make_main_menu 'enterprise_compliance_lob', 'Enterprise Compliance LOB', enterprise_compliance_lob_menu
Navigation.make_main_menu 'funder', 'Funding', funding_menu
Navigation.make_main_menu 'hr','Human Resources',         hr_menu
Navigation.make_main_menu 'init_disclose', 'Initial Disclosure', init_disclose_menu
Navigation.make_main_menu 'lock_desk','Lock Desk',   lockdesk_menu
Navigation.make_main_menu 'operations','Operations',        ops_menu
Navigation.make_main_menu 'pac','PAC',        pac_menu
Navigation.make_main_menu 'post_closing','Post Closing',postclosing_menu
Navigation.make_main_menu 'preclosing','PreClosing',preclosing_menu
Navigation.make_main_menu 'registration','Registration',registration_menu
Navigation.make_main_menu 'risk_management','Risk Mgmt',       risk_menu
Navigation.make_main_menu 'sales','Sales',      sales_menu
Navigation.make_main_menu 'secondary','Secondary Marketing',     secmar_menu
Navigation.make_main_menu 'servicing_acquisition','Servicing Acquisition',      serva_menu
Navigation.make_main_menu 'servicing','Servicing',  servicing_menu
Navigation.make_main_menu 'suspense','Suspense', suspense_menu
Navigation.make_main_menu 'uw','Underwriting',         uw_menu
Navigation.make_main_menu 'loan_delivery','Loan Delivery', delivery_menu
Navigation.make_main_menu 'evening_shift','Evening Shift', evening_menu
Navigation.make_main_menu 'title_vendors', 'Title Vendors', title_vendors_menu

Navigation.tagged_with(['uw'], exclude: true).roots.each do |n|
  n.role_list << ['admin', n.name]
  n.save
end

Navigation.tagged_with(['hr', 'accounting'], exclude: true).roots.each do |n|
  n.role_list << 'bpm'
  n.save
end

Navigation.tagged_with(['uw']).roots.each do |n|
  n.role_list << ['underwriter', 'underwriter_employee', 'underwriter_manager', 'registration']
  n.save
end
