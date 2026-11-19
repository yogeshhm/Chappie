import 'package:flutter_test/flutter_test.dart';
import 'package:falcon_crm/models/lead_model.dart';
import 'package:falcon_crm/models/call_log_model.dart';
import 'package:falcon_crm/data/initial_leads.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Initial leads dataset has 14 leads with Outreach status', () {
    expect(initialFalconateLeads.length, 14);

    final shrinidhi = initialFalconateLeads.firstWhere((l) => l.id == '1');
    expect(shrinidhi.businessName, 'Shrinidhi Enterprises');
    expect(shrinidhi.hasCaution, true);
    expect(shrinidhi.cautionNotes.contains('HVAC'), true);
    expect(shrinidhi.hasPhone, true);
    expect(shrinidhi.callStatus, 'Outreach');
    expect(shrinidhi.createdBy, 'Yogesh');
    expect(shrinidhi.updatedBy, 'Yogesh');

    final falconNest = initialFalconateLeads.firstWhere((l) => l.id == '5');
    expect(falconNest.businessName, 'FalconNest Constructions');
    expect(falconNest.leadPriority, 'Low');
    expect(falconNest.hasWebsite, true);
  });

  test('LeadModel serialization and deserialization with Cadence user logging and lost reason', () {
    final lead = LeadModel(
      id: 'test_1',
      businessName: 'Falconate Digital',
      phoneNumbers: '9876543210',
      leadPriority: 'High',
      callStatus: 'Lost',
      lostReason: 'Price too high for client budget',
      createdBy: 'Yogesh',
      updatedBy: 'Yogesh',
    );

    final map = lead.toMap();
    final recreated = LeadModel.fromMap(map);

    expect(recreated.id, lead.id);
    expect(recreated.businessName, lead.businessName);
    expect(recreated.primaryPhone, '9876543210');
    expect(recreated.isHighPriority, true);
    expect(recreated.callStatus, 'Lost');
    expect(recreated.lostReason, 'Price too high for client budget');
    expect(recreated.createdBy, 'Yogesh');
    expect(recreated.updatedBy, 'Yogesh');
  });

  test('LeadModel.normalizeStatus normalizes legacy statuses into 6 official pipeline stages', () {
    expect(LeadModel.normalizeStatus('Not Called'), 'Outreach');
    expect(LeadModel.normalizeStatus('Called - No Answer'), 'Outreach');
    expect(LeadModel.normalizeStatus('Follow-up Scheduled'), 'Outreach');
    expect(LeadModel.normalizeStatus('Connected'), 'Outreach');
    expect(LeadModel.normalizeStatus('outreach'), 'Outreach');
    expect(LeadModel.normalizeStatus('Interested'), 'Interested');
    expect(LeadModel.normalizeStatus('Demo'), 'Demo');
    expect(LeadModel.normalizeStatus('Deal'), 'Deal');
    expect(LeadModel.normalizeStatus('Closed Won'), 'Deal');
    expect(LeadModel.normalizeStatus('Junk'), 'Junk');
    expect(LeadModel.normalizeStatus('Invalid Number'), 'Junk');
    expect(LeadModel.normalizeStatus('Lost'), 'Lost');
    expect(LeadModel.normalizeStatus('Not Interested'), 'Lost');
  });

  test('CallLogModel serialization and Cadence user logging by Yogesh', () {
    final log = CallLogModel(
      id: 'log_1',
      leadId: 'test_1',
      outcome: 'Interested',
      notes: 'Spoke with Yogesh on call, scheduled demo',
      loggedBy: 'Yogesh',
    );

    final map = log.toMap();
    final recreated = CallLogModel.fromMap(map);

    expect(recreated.id, 'log_1');
    expect(recreated.leadId, 'test_1');
    expect(recreated.outcome, 'Interested');
    expect(recreated.loggedBy, 'Yogesh');
  });

  test('LeadModel.allPhones parses multiple phone numbers accurately without mutating digits', () {
    final lead = LeadModel(
      id: 'test_multi_phone',
      businessName: 'Shivjal Group',
      phoneNumbers: '7676606019, 9901419777, 9845012345',
    );

    expect(lead.allPhones.length, 3);
    expect(lead.allPhones[0], '7676606019');
    expect(lead.allPhones[1], '9901419777');
    expect(lead.allPhones[2], '9845012345');
    expect(lead.primaryPhone, '7676606019');
  });

  test('LeadModel.allPhones handles single phone and empty phones without crash', () {
    final emptyLead = LeadModel(
      id: 'test_empty',
      businessName: 'No Phone Corp',
      phoneNumbers: '',
    );
    expect(emptyLead.allPhones, isEmpty);
    expect(emptyLead.primaryPhone, isNull);
    expect(emptyLead.hasPhone, false);

    final singleLead = LeadModel(
      id: 'test_single',
      businessName: 'Single Phone Corp',
      phoneNumbers: '9439321339',
    );
    expect(singleLead.allPhones, ['9439321339']);
    expect(singleLead.primaryPhone, '9439321339');
    expect(singleLead.hasPhone, true);
  });
}
