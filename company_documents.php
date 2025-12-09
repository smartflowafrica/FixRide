<?php
require 'inc/checklogin.php';
require 'inc/Connection.php';
require 'inc/header.php';

if (empty($_GET['id'])) {
    header('Location: company_list.php');
    exit;
}

$company_id = intval($_GET['id']);

// Handle document verification
if ($_SERVER['REQUEST_METHOD'] == 'POST') {
    $doc_id = intval($_POST['doc_id']);
    $action = $_POST['action'];
    
    if ($action == 'verify') {
        $car->query("UPDATE tbl_company_document SET status = 'verified', verified_at = NOW() WHERE id = $doc_id");
        $msg = "Document verified!";
    } elseif ($action == 'reject') {
        $reason = $car->real_escape_string($_POST['reason'] ?? '');
        $car->query("UPDATE tbl_company_document SET status = 'rejected', rejection_reason = '$reason' WHERE id = $doc_id");
        $msg = "Document rejected";
    }
    
    // Check if all required docs are verified
    $verified_count = $car->query("SELECT COUNT(*) as cnt FROM tbl_company_document 
        WHERE company_id = $company_id AND status = 'verified'")->fetch_assoc()['cnt'];
    
    if ($verified_count >= 2) {
        $car->query("UPDATE tbl_company SET is_verified = 1, status = 'active' WHERE id = $company_id");
    }
    
    echo "<script>alert('$msg'); window.location.reload();</script>";
}

$company = $car->query("SELECT * FROM tbl_company WHERE id = $company_id")->fetch_assoc();
if (!$company) {
    echo "<script>alert('Company not found'); window.location='company_list.php';</script>";
    exit;
}

$documents = $car->query("SELECT * FROM tbl_company_document WHERE company_id = $company_id ORDER BY uploaded_at DESC");
?>

<div class="page-wrapper">
    <div class="page-content">
        <div class="page-breadcrumb d-none d-sm-flex align-items-center mb-3">
            <div class="breadcrumb-title pe-3">Company Documents</div>
            <div class="ps-3">
                <nav aria-label="breadcrumb">
                    <ol class="breadcrumb mb-0 p-0">
                        <li class="breadcrumb-item"><a href="dashboard.php"><i class="bx bx-home-alt"></i></a></li>
                        <li class="breadcrumb-item"><a href="company_list.php">Companies</a></li>
                        <li class="breadcrumb-item"><a href="company_details.php?id=<?= $company_id ?>"><?= $company['company_name'] ?></a></li>
                        <li class="breadcrumb-item active">Documents</li>
                    </ol>
                </nav>
            </div>
        </div>

        <div class="card">
            <div class="card-header d-flex justify-content-between align-items-center">
                <h5 class="mb-0">Documents for <?= $company['company_name'] ?></h5>
                <div>
                    <?php if ($company['is_verified']): ?>
                    <span class="badge bg-success fs-6"><i class="bx bx-check"></i> Company Verified</span>
                    <?php else: ?>
                    <span class="badge bg-warning fs-6">Verification Pending</span>
                    <?php endif; ?>
                </div>
            </div>
            <div class="card-body">
                <?php if ($documents->num_rows == 0): ?>
                <div class="alert alert-info">
                    <i class="bx bx-info-circle"></i> No documents uploaded yet.
                </div>
                <?php else: ?>
                <div class="row">
                    <?php while ($doc = $documents->fetch_assoc()): ?>
                    <div class="col-md-4 mb-4">
                        <div class="card h-100">
                            <div class="card-header d-flex justify-content-between">
                                <span class="text-uppercase fw-bold"><?= str_replace('_', ' ', $doc['document_type']) ?></span>
                                <?php
                                $badge = match($doc['status']) {
                                    'verified' => 'success',
                                    'pending' => 'warning',
                                    'rejected' => 'danger',
                                    'expired' => 'secondary',
                                    default => 'secondary'
                                };
                                ?>
                                <span class="badge bg-<?= $badge ?>"><?= ucfirst($doc['status']) ?></span>
                            </div>
                            <div class="card-body">
                                <?php
                                $ext = strtolower(pathinfo($doc['document_url'], PATHINFO_EXTENSION));
                                if (in_array($ext, ['jpg', 'jpeg', 'png', 'gif'])):
                                ?>
                                <a href="<?= $doc['document_url'] ?>" target="_blank">
                                    <img src="<?= $doc['document_url'] ?>" alt="Document" class="img-fluid rounded mb-3" style="max-height: 200px;">
                                </a>
                                <?php else: ?>
                                <div class="text-center p-4 bg-light rounded mb-3">
                                    <i class="bx bx-file-blank fs-1"></i>
                                    <p class="mb-0"><?= strtoupper($ext) ?> File</p>
                                    <a href="<?= $doc['document_url'] ?>" target="_blank" class="btn btn-sm btn-outline-primary mt-2">
                                        <i class="bx bx-download"></i> View/Download
                                    </a>
                                </div>
                                <?php endif; ?>
                                
                                <?php if ($doc['document_name']): ?>
                                <p class="mb-1"><strong>Name:</strong> <?= $doc['document_name'] ?></p>
                                <?php endif; ?>
                                <?php if ($doc['expiry_date']): ?>
                                <p class="mb-1"><strong>Expires:</strong> <?= date('M d, Y', strtotime($doc['expiry_date'])) ?></p>
                                <?php endif; ?>
                                <p class="mb-1 text-muted"><small>Uploaded: <?= date('M d, Y H:i', strtotime($doc['uploaded_at'])) ?></small></p>
                                
                                <?php if ($doc['status'] == 'rejected' && $doc['rejection_reason']): ?>
                                <div class="alert alert-danger mt-2 mb-0 py-2">
                                    <small><strong>Rejection reason:</strong> <?= $doc['rejection_reason'] ?></small>
                                </div>
                                <?php endif; ?>
                            </div>
                            
                            <?php if ($doc['status'] == 'pending'): ?>
                            <div class="card-footer">
                                <form method="POST" class="d-inline">
                                    <input type="hidden" name="doc_id" value="<?= $doc['id'] ?>">
                                    <input type="hidden" name="action" value="verify">
                                    <button type="submit" class="btn btn-success btn-sm">
                                        <i class="bx bx-check"></i> Verify
                                    </button>
                                </form>
                                <button type="button" class="btn btn-danger btn-sm" data-bs-toggle="modal" data-bs-target="#rejectModal<?= $doc['id'] ?>">
                                    <i class="bx bx-x"></i> Reject
                                </button>
                            </div>
                            
                            <!-- Reject Modal -->
                            <div class="modal fade" id="rejectModal<?= $doc['id'] ?>" tabindex="-1">
                                <div class="modal-dialog">
                                    <div class="modal-content">
                                        <div class="modal-header">
                                            <h5 class="modal-title">Reject Document</h5>
                                            <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                                        </div>
                                        <form method="POST">
                                            <div class="modal-body">
                                                <input type="hidden" name="doc_id" value="<?= $doc['id'] ?>">
                                                <input type="hidden" name="action" value="reject">
                                                <div class="mb-3">
                                                    <label class="form-label">Rejection Reason</label>
                                                    <textarea name="reason" class="form-control" rows="3" required placeholder="Explain why this document is being rejected..."></textarea>
                                                </div>
                                            </div>
                                            <div class="modal-footer">
                                                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                                                <button type="submit" class="btn btn-danger">Reject Document</button>
                                            </div>
                                        </form>
                                    </div>
                                </div>
                            </div>
                            <?php endif; ?>
                        </div>
                    </div>
                    <?php endwhile; ?>
                </div>
                <?php endif; ?>
            </div>
        </div>
    </div>
</div>

<?php require 'inc/footer.php'; ?>
