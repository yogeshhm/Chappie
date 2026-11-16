import 'package:flutter_test/flutter_test.dart';
import 'package:falcon_crm/models/lead_model.dart';
import 'package:falcon_crm/data/initial_leads.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Initial leads dataset has 14 leads with correct verified data', () {
    expect(initialFalconateLeads.length, 14);

    final shrinidhi = initialFalconateLeads.firstWhere((l) => l.id == '1');
    expect(shrinidhi.businessName, 'Shrinidhi Enterprises');
    expect(shrinidhi.hasCaution, true);
    expect(shrinidhi.cautionNotes.contains('HVAC'), true);
    expect(shrinidhi.hasPhone, true);

    final falconNest = initialFalconateLeads.firstWhere((l) => l.id == '5');
    expect(falconNest.businessName, 'FalconNest Constructions');
    expect(falconNest.leadPriority, 'Low');
    expect(falconNest.hasWebsite, true);
  });

  test('LeadModel serialization and deserialization', () {
    final lead = LeadModel(
      id: 'test_1',
      businessName: 'Falconate Digital',
      phoneNumbers: '9876543210',
      leadPriority: 'High',
      callStatus: 'Not Called',
    );

    final map = lead.toMap();
    final recreated = LeadModel.fromMap(map);

    expect(recreated.id, lead.id);
    expect(recreated.businessName, lead.businessName);
    expect(recreated.primaryPhone, '9876543210');
    expect(recreated.isHighPriority, true);
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
